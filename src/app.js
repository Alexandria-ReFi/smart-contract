import OpenAI from "openai";
import bodyParser from "body-parser";
import express from "express";
import axios from "axios";
import * as fcl from "@onflow/fcl"
const app = express();

fcl.config({
  "accessNode.api": "https://rest-testnet.onflow.org" // Endpoint set to Testnet
})

const result = await fcl.query({
    cadence: `
        import Alexandria from 0x262018356ee8cf79

        access(all) 
        fun main(bookTitle: String): &Alexandria.Book?  {

            return Alexandria.getBook(bookTitle: bookTitle)
        } 
    `,args: (arg, t) => [
        arg("The Awakening", t.String), // a: Int
      ],
});
console.log(result)
app.use(bodyParser.json());


const openai = new OpenAI({
  apiKey: "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", // Make sure to set your API key
});


const PORT = process.env.PORT || 3000;
const OPENAI_API_KEY = "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";
const LIBRARY_INDEX = "http://localhost:9200/books"; // Elasticsearch index for books


// Function to query books and get AI-generated responses
async function queryLibrarian(question) {
    try {
        // Step 1: Search Library Database for Relevant Books
        const topBook = result
        console.log(topBook)

        console.log(`Found book: ${topBook.Title}`);

        // Step 2: Ask OpenAI for Answer from Book
        const response = await axios.post(
            'https://api.openai.com/v1/chat/completions',
            {
                model: 'gpt-4o',
                messages: [
                    { role: 'system', content: "You are a librarian AI. Answer based on the book's content." },
                    { role: 'user', content: `The book says:\n"${topBook.Summary}"\n\nUser asks: ${question}` }
                ],
                temperature: 0.7
            },
            {
                headers: { 'Authorization': `Bearer ${OPENAI_API_KEY}`, 'Content-Type': 'application/json' }
            }
        );
        console.log(response.data.choices[0].message.content)
        return response.data.choices[0].message.content;
    } catch (error) {
        console.error("Error:", error.response?.data || error.message);
        return "There was an error processing your request.";
    }
}

// Chatbot API Endpoint
app.post('/chat', async (req, res) => {
    const userMessage = req.body.message;
    if (!userMessage) {
        return res.status(400).json({ error: "Message is required" });
    }

    const reply = await queryLibrarian(userMessage);
    res.json({ reply });
});

// Start Server
app.listen(PORT, () => {
    console.log(`Librarian chatbot running on port ${PORT}`);
});

queryLibrarian("What happens in the second chapter?")