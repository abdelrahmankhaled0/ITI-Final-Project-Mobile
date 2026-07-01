import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import multer from 'multer';
import fs from 'fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { GoogleGenerativeAI } from '@google/generative-ai';

dotenv.config();

const serviceAccount = JSON.parse(fs.readFileSync('./serviceAccountKey.json', 'utf8'));
initializeApp({
  credential: cert(serviceAccount)
});
const db = getFirestore();

const app = express();
app.use(cors());
app.use(express.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const upload = multer({ dest: 'uploads/' });

function fileToGenerativePart(path, mimeType) {
  return {
    inlineData: {
      data: Buffer.from(fs.readFileSync(path)).toString("base64"),
      mimeType
    },
  };
}

// 🌟 Reliable text-based language detection (Arabic Unicode block check).
// This is more deterministic than letting the model guess, so we use it
// to give the model an explicit, unambiguous hint whenever the user types text.
function detectLanguage(text) {
  if (!text || !text.trim()) return null;
  const arabicPattern = /[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]/;
  return arabicPattern.test(text) ? 'ar' : 'en';
}

app.post('/api/chat', upload.fields([{ name: 'voice', maxCount: 1 }, { name: 'image', maxCount: 1 }]), async (req, res) => {
  try {
    const { userId, userName, message } = req.body;

    let realBusinesses = [];
    let userTickets = [];

    // جلب البيانات من الفايرستور
    try {
      const businessSnapshot = await db.collection('businesses').where('isOperational', '==', true).get();

      realBusinesses = await Promise.all(businessSnapshot.docs.map(async (doc) => {
        const data = doc.data();
        let servicesList = [];

        try {
          const servicesSnapshot = await doc.ref.collection('services').get();
          servicesList = servicesSnapshot.docs.map(serviceDoc => ({
            serviceId: serviceDoc.id,
            serviceName: serviceDoc.data().name || serviceDoc.data().serviceName || "خدمة عامة",
            serviceImage: serviceDoc.data().imageURI || serviceDoc.data().imageUrl || "https://placedog.net/500"
          }));
        } catch (e) {
          console.log(`Could not fetch services for business ${doc.id}`);
        }

        return {
          businessId: doc.id,
          businessName: data.name,
          category: data.category,
          services: servicesList
        };
      }));

      if (userId) {
        const ticketsSnapshot = await db.collection('tickets').where('userId', '==', userId).get();
        userTickets = ticketsSnapshot.docs.map(doc => {
          const data = doc.data();
          return {
            ticketId: doc.id,
            businessName: data.bussinessName,
            serviceName: data.serviceName,
            status: data.status,
            ticketNumber: data.ticketNumber
          };
        });
      }
    } catch (dbError) {
      console.error("Error fetching from Firestore:", dbError);
    }

    const currentCairoTime = new Date().toLocaleString("en-US", { timeZone: "Africa/Cairo" });

    // 🌟 Detect the language of the typed text (if any) up front. We pass this
    // to the model as a strong hint instead of leaving language detection
    // entirely up to the LLM for the text case.
    const detectedTextLang = detectLanguage(message);

    // 🌟 Parse the conversation history sent by the app (array of {role, text}).
    // Without this, every request looked like a brand-new conversation to
    // Gemini, which is why it kept greeting/introducing itself every turn.
    let chatHistory = [];
    try {
      chatHistory = req.body.history ? JSON.parse(req.body.history) : [];
      if (!Array.isArray(chatHistory)) chatHistory = [];
    } catch (e) {
      console.log("Could not parse history field, defaulting to empty:", e.message);
      chatHistory = [];
    }
    const isFirstMessage = chatHistory.length === 0;

    const SYSTEM_PROMPT = `
You are Taborq's Smart AI Assistant — a professional, friendly booking concierge for clinics and beauty centers.

--- LANGUAGE POLICY (STRICT — FOLLOW EXACTLY) ---
You must detect the language the user is communicating in for THIS specific message — whether it arrives as typed text, a voice note, or handwriting/text inside an image — and reply ENTIRELY in that same language. Never mix Arabic and English in one reply (brand names and proper nouns like "Taborq" or a business's own name may stay as-is).

1. TEXT INPUT: If the user typed in Arabic, respond in clear, professional Modern Standard Arabic — warm and easy to read, not overly classical or robotic. If they typed in English, respond in professional, friendly English.
2. VOICE INPUT: Listen to the audio, identify the spoken language (Arabic or English, including Arabic dialects), and reply fully in that language. Never reply in a different language than the one spoken.
3. IMAGE INPUT: If the image contains handwritten or printed text, read it and detect its language, then reply in that same language.
4. MIXED OR AMBIGUOUS INPUT (e.g. an image with no text, or a voice note with no clear words): default to the language of the most recent typed message in this request. If there is no text at all, default to Arabic.
5. Never add meta-notes like "(translated)" or "(in Arabic)" — just answer naturally, as a native professional speaker of that language would.
6. Keep tone consistent across languages: warm, concise, trustworthy, and professional — this is a real healthcare/beauty booking platform, so clarity and accuracy matter more than flair.
-----------------------------

--- REAL DATABASE CONTEXT ---
CURRENT REAL TIME: ${currentCairoTime} (Use this to calculate dynamic, valid booking dates. NEVER output placeholders like YYYY-MM-DD).
AVAILABLE BUSINESSES & SERVICES:
${JSON.stringify(realBusinesses)}

USER'S CURRENT BOOKINGS:
${JSON.stringify(userTickets)}
-----------------------------

--- CONVERSATION CONTEXT (STRICT) ---
You are continuing an ONGOING conversation. The prior turns are provided to you as real conversation history (not as a one-off message) — read and use them like a human agent who remembers everything said so far.
- Only greet the user and introduce yourself ("Welcome to Taborq...", "I'm Taborq's assistant...", etc.) if this is truly the FIRST message of the conversation. You will get an explicit [System Hint] telling you whether this is the first message or a continuing one — follow it exactly.
- On every later turn, skip greetings and self-introductions entirely. Respond directly to what the user is asking, as a continuation of the same conversation — don't restart, don't re-explain who you are, don't re-list things already covered unless the user asks again.
- Stay consistent with anything already discussed (e.g. if the user already picked a business or service earlier in the conversation, remember that instead of asking again).
-----------------------------

CRITICAL INSTRUCTIONS:
1. GREETINGS: Only on the first message of the conversation (per CONVERSATION CONTEXT above), reply warmly and introduce yourself briefly and professionally, and set "is_booking_proposal" to false.
2. SERVICE SUGGESTIONS: If the user asks for general suggestions (no specific business named), recommend the most relevant matches and include the exact service details in the "suggested_services" array so the app can display them as clickable visual cards.
2b. BUSINESS-SPECIFIC REQUESTS (STRICT FILTER — applies to text, voice, AND image): If the user names or asks about ONE specific business — in any language, spelling, or transliteration (e.g. "Acme Wellness", "اسم العيادة الفلاني", or any mistyped/transliterated variant of a business's actual name) — you must return ONLY that business's services in "suggested_services", and your "reply" must talk ONLY about that business. Do not include, mention, or mix in services from any other business, even if they seem relevant or popular. Match the name ONLY against the businessName values listed in AVAILABLE BUSINESSES below (typos, transliteration, partial names are fine when matching against THOSE real names) — but once you identify the business, filter to it exclusively. If that business genuinely has no listed services, say so honestly instead of substituting services from elsewhere.
CRITICAL ANTI-GUESSING RULE: The example names above ("Acme Wellness", etc.) are illustrations of the MATCHING STYLE only — they are NOT real businesses and must never be treated as valid matches. A real business name only counts if it actually appears in AVAILABLE BUSINESSES below for THIS request. If you are not reasonably confident which real business the user meant, or if no business in AVAILABLE BUSINESSES reasonably matches what was said/written, you MUST tell the user clearly that you couldn't find it. Never substitute, guess, or default to any other business name — including ones that may have come up earlier in this conversation or in these instructions — just because it's familiar or convenient.3. MULTIMODAL (IMAGES/VOICE): If the user uploads an image or voice, analyze it carefully (e.g., if it's handwriting like "EverGlow", read it and suggest their services) — and remember to follow both the LANGUAGE POLICY above and the BUSINESS-SPECIFIC FILTER (2b) based on what you detect in that image or audio.
NOTE: The list above is the COMPLETE and ONLY set of valid businesses for this request. Any business name not in this exact list does not exist in our system, regardless of how similar it sounds to a known brand or to anything mentioned earlier.
4. BOOKING CONFIGURATION: When the user decides to book, output an accurate "bookingTime" based on the Current Real Time provided above.
5. PROFESSIONAL TONE: Avoid overly casual slang in either language. Be concise, confident, and helpful — like a well-trained human receptionist, not a generic chatbot.

STRUCTURED OUTPUT FORMATS:

FOR CONVERSATIONS, GREETINGS, IMAGE ANALYSIS, AND SERVICE SUGGESTIONS:
{
  "is_booking_proposal": false,
  "reply": "Your text response here, in the detected language.",
  "suggested_services": [
    {
      "serviceId": "exact_id",
      "serviceName": "exact_name",
      "serviceImage": "exact_url",
      "businessId": "exact_business_id"
    }
  ]
}

WHEN BOOKING IS DETECTED & AGREED UPON:
{
  "is_booking_proposal": true,
  "reply": "A short confirmation message in the detected language.",
  "booking_details": {
    "businessId": "Real businessId",
    "bussinessName": "Real businessName",
    "serviceId": "Real serviceId",
    "serviceName": "Real serviceName",
    "bookingTime": "2026-06-15T14:30:00",
    "ticketNumber": 1
  }
}

Always return valid JSON only. Do not wrap response in markdown code blocks.
`;

    // 🌟 systemInstruction keeps the rules/database context separate from the
    // actual back-and-forth conversation, which is the correct way to give
    // Gemini both a persona AND real multi-turn memory at the same time.
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      systemInstruction: SYSTEM_PROMPT,
      generationConfig: { responseMimeType: "application/json" }
    });

    // 🌟 Turn the app's saved history into real Gemini conversation turns
    // (alternating user/model), so the model actually remembers what was
    // already said instead of treating every request as a brand-new chat.
    const rawHistoryContents = chatHistory
      .filter(turn => turn && typeof turn.text === 'string' && turn.text.trim() !== '')
      .map(turn => ({
        role: turn.role === 'model' ? 'model' : 'user',
        parts: [{ text: turn.text }]
      }));

    // 🌟 Defensive: the Gemini API expects roles to strictly alternate.
    // Merge any accidental back-to-back same-role turns (e.g. user sent two
    // messages quickly before a reply came back) into a single turn.
    const historyContents = [];
    for (const turn of rawHistoryContents) {
      const last = historyContents[historyContents.length - 1];
      if (last && last.role === turn.role) {
        last.parts.push(...turn.parts);
      } else {
        historyContents.push({ role: turn.role, parts: [...turn.parts] });
      }
    }

    // 🌟 Build the CURRENT turn's parts (hints, media, and/or typed text).
    const currentParts = [
      { text: `Context: UserID=${userId}, UserName=${userName}.` },
      {
        text: isFirstMessage
          ? "[System Hint: This is the FIRST message of the conversation — greet the user briefly and introduce yourself, per CONVERSATION CONTEXT.]"
          : "[System Hint: This is a CONTINUING conversation — do NOT greet or reintroduce yourself, just respond naturally with full context, per CONVERSATION CONTEXT.]"
      }
    ];

    // 🌟 If we detected a language from typed text, tell the model explicitly —
    // removes any ambiguity for the most common case (pure text messages).
    if (detectedTextLang) {
      currentParts.push({
        text: `[System Hint: The user's typed text is in ${detectedTextLang === 'ar' ? 'Arabic' : 'English'}. Reply fully in ${detectedTextLang === 'ar' ? 'Arabic' : 'English'} as instructed by the LANGUAGE POLICY.]`
      });
    }

//    if (req.files && req.files['voice']) {
//      const voiceFile = req.files['voice'][0];
//      let mime = voiceFile.mimetype;
//      if (!mime || mime.includes('octet-stream')) mime = 'audio/mp4';
//
//      const audioPart = fileToGenerativePart(voiceFile.path, mime);
//      currentParts.push(audioPart);
//      currentParts.push({ text: "Analyze this voice note, detect the language spoken (Arabic or English), and respond to the user's request fully in that same language, per the LANGUAGE POLICY. If a specific business name is mentioned in the audio, apply the BUSINESS-SPECIFIC FILTER (rule 2b): return services for that business ONLY, ignoring all others." });
//      fs.unlinkSync(voiceFile.path);
//    }

       // معالجة الملف الصوتي
           if (req.files && req.files['voice'] && req.files['voice'].length > 0) {
             const voiceFile = req.files['voice'][0];
             let mime = voiceFile.mimetype;

             // 👈 هنا بنعالج مشكلة الـ octet-stream اللي جاية من فلاتر
             // Gemini بيحتاج 'audio/mp4' عشان يقدر يحلل ملفات الـ .m4a بشكل صحيح
             if (!mime || mime.includes('octet-stream')) {
               mime = 'audio/mp4';
             }

             console.log(`🎤 Sending Audio to Gemini: Size = ${voiceFile.size} bytes, Mime = ${mime}`);

             const audioPart = fileToGenerativePart(voiceFile.path, mime);
             currentParts.push(audioPart);
             currentParts.push({
               text: "Analyze this voice note, detect the language spoken (Arabic or English), and respond to the user's request fully in that same language, per the LANGUAGE POLICY. If a specific business name is mentioned in the audio, apply the BUSINESS-SPECIFIC FILTER (rule 2b): return services for that business ONLY, ignoring all others."
             });

             // مسح الملف من السيرفر بعد ما ضفناه للـ prompt
             fs.unlinkSync(voiceFile.path);
           }

    if (req.files && req.files['image']) {
      const imageFile = req.files['image'][0];
      let mime = imageFile.mimetype;
      if (!mime || mime.includes('octet-stream')) mime = 'image/jpeg';

      const imagePart = fileToGenerativePart(imageFile.path, mime);
      currentParts.push(imagePart);
      currentParts.push({ text: "Analyze this image input. If it contains handwritten or printed text like a business name, extract it, detect its language, and suggest their services from our database — replying fully in the detected language, per the LANGUAGE POLICY. Apply the BUSINESS-SPECIFIC FILTER (rule 2b): return services for that one business ONLY, ignoring all others." });
      fs.unlinkSync(imageFile.path);
    }

    if (message && message.trim() !== '') {
      currentParts.push({ text: `User Message: ${message}` });
    }

    const contents = [
      ...historyContents,
      { role: 'user', parts: currentParts }
    ];

    console.log('Sending request to Gemini...');
    const result = await model.generateContent({ contents });
    let responseText = result.response.text();

    let cleanedText = responseText;
    const jsonMatch = responseText.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      cleanedText = jsonMatch[0];
    }

    console.log("Extracted JSON:", cleanedText);

    let aiOutput;
    try {
      aiOutput = JSON.parse(cleanedText);
    } catch (parseError) {
      // 🌟 This is one of the most common real causes behind the generic
      // "trouble connecting" message: Gemini occasionally returns text that
      // isn't valid JSON (extra prose, truncated output, etc.) despite
      // responseMimeType being set to JSON. Logging the RAW text here is
      // essential to seeing exactly what the model actually sent back.
      console.error('❌ Failed to parse Gemini response as JSON.');
      console.error('Raw response text was:', responseText);
      throw parseError;
    }

    return res.status(200).json(aiOutput);

  } catch (error) {
    // 🌟 Log everything we can about the real failure — message, full
    // error object, and (if present) any structured details the Gemini SDK
    // attaches (e.g. quota/rate-limit errors, safety blocks, etc.).
    console.error('Error in Gemini Backend Pipeline:', error?.message || error);
    console.error('Full error object:', error);

    const { message: lastMessage } = req.body || {};
    const fallbackLang = detectLanguage(lastMessage);

    // 🌟 A 429 here almost always means the Gemini API free-tier daily/
    // per-minute quota was exceeded — not an actual outage. Surface that
    // clearly instead of the generic "trouble connecting" message, since
    // it's a completely different (and very common) situation.
    const isQuotaError = error?.status === 429;
    const fallbackReply = isQuotaError
      ? (fallbackLang === 'ar'
          ? 'وصلنا للحد الأقصى المسموح به من الطلبات لليوم. من فضلك حاول مرة أخرى بعد قليل.'
          : "We've reached today's usage limit for the AI assistant. Please try again in a little while.")
      : (fallbackLang === 'ar'
          ? 'عذرًا، حدث خطأ أثناء معالجة طلبك. من فضلك حاول مرة أخرى.'
          : 'Sorry, I encountered an error processing your request. Please try again.');

    // 🌟 IMPORTANT: return 200 here (not 4xx/5xx). The Flutter app only
    // treats an HTTP 200 response as "render data['reply'] normally" —
    // anything else gets replaced by the app's own generic fallback text,
    // which would silently throw away this specific, localized message
    // (e.g. the quota-exceeded explanation) and show a vague one instead.
    return res.status(200).json({
      is_booking_proposal: false,
      reply: fallbackReply,
    });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Taborq Backend running on port ${PORT}`);
});


