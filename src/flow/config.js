import * as fcl from "@onflow/fcl"

fcl.config({
  "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn", // Endpoint set to Testnet
})

fcl.authenticate()

export const result = await fcl.query({
    cadence: `
        import Alexandria from 0x262018356ee8cf79

        access(all) 
        fun main(bookTitle: String): &Alexandria.Book?  {

            return Alexandria.getBook(bookTitle: bookTitle)
        } 
    `,
  });
  console.log(result)