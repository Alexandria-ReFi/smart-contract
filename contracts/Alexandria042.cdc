access(all)
contract Alexandria {
    // -----------------------------------------------------------------------
	// Alexandria Contract-level information
	// -----------------------------------------------------------------------
	access(self) let libraryInfo: {String: AnyStruct}
    access(self) let titles: {String: String}
    access(self) let authors: {String: [String]}
    access(self) let categories: {String: [String]}

	// Paths
    access(all) let LibrarianStoragePath: StoragePath
    // -----------------------------------------------------------------------
	// Alexandria Book Resource
	// -----------------------------------------------------------------------
    access(all)
    resource Book {
        access(all) let Title: String
        access(all) let Author: String
        access(all) let Category: String
        access(all) let Summary: String
        access(all) let Chapters: [Chapter]

        init(
            _ title: String,
            _ author: String,
            _ category: String,
            _ description: String,
        ) {
            self.Title = title
            self.Author = author
            self.Category = category
            self.Summary = description
            self.Chapters = []
        }
        // Resource functionality
        access(all)
        fun addNewChapter(_ chapter: Chapter): Int {
            self.Chapters.append(chapter)

            return self.Chapters.length
        }
        access(all)
        fun removeLastChapter(): Int {
            let book = self.Chapters.removeLast()

            return self.Chapters.length
        }
    }

    access(all)
    struct Chapter {
        access(all) let title: String
        access(all) let index: Int
        access(all) let paragraphs: [String]

        init(
            _ title: String,
            _ index: Int,
            _ paragraphs: [String]
        ) {
            self.title = title
            self.index = index
            self.paragraphs = paragraphs
        }
    }

    // -----------------------------------------------------------------------
	// Alexandria Librarian Resource
	// -----------------------------------------------------------------------

    access(all)
    resource Librarian {
        // Function to add a book to the library
        access(all)
        fun addBook(
            _ title: String,
            _ author: String,
            _ category: String,
            _ description: String,
        ) {
            pre {
                Alexandria.titles[title] != nil: "This book is already in the Library."
            }
            // create new book resource
            let newBook <- create Book(title, author, category, description)
            // create new path identifier for book
            let identifier = "Alexandria_Library_".concat(Alexandria.account.address.toString()).concat("_".concat(title))
            // Add the book's details to the library's catalog
            Alexandria.titles[title] = newBook.Title
            Alexandria.titles[author] = newBook.Author
            // Check if this category already exists
            if Alexandria.categories[category] == nil {
                Alexandria.categories[category] = []
            } else {
                // Add title to the list of titles under that category
                Alexandria.categories[category]!.append(title)    
            }
            // add new book to the library
		    Alexandria.account.storage.save(<- newBook, to: StoragePath(identifier: identifier)!)
        }
        // Add a chapter to a book
        access(all)
        fun addChapter(
            bookTitle: String,
            chapter: Chapter
        ) { 
			// let library = Alexandria.account.storage.borrow<&Alexandria.LibraryStorage>(from: Alexandria.LibraryStoragePath)!

            // let book = library.getBook(bookTitle)!
            // let chapters = book.addNewChapter(chapter)

            // return chapters
        }
        // create a new Librarianistrator resource
		access(all)
        fun createLibrarian(): @Librarian {
			return <- create Librarian()
		}
		// change Alexandria of library info
		access(all)
        fun changeField(key: String, value: AnyStruct) {
			Alexandria.libraryInfo[key] = value
		}
    }


    // -----------------------------------------------------------------------
	// Alexandria Public Services
	// -----------------------------------------------------------------------

    access(all)
    fun getBook(bookTitle: String): &Book? {
        // create book path identifier based on title
        let identifier = "Alexandria_Library_".concat(Alexandria.account.address.toString()).concat("_".concat(bookTitle))
        
        let book = Alexandria.account.storage.borrow<&Alexandria.Book>(from: StoragePath(identifier: identifier)!)

        return book
    }

    init() {
        let identifier = "Alexandria_Library_".concat(self.account.address.toString())

        self.LibrarianStoragePath = StoragePath(identifier: identifier.concat("Librarian"))!
        
        self.libraryInfo = {}
        self.titles = {}
        self.authors = {}
        self.categories = {
            "Adventure": [],
            "Biography": [],
            "Dystopian": [],
            "Fantasy": [],
            "Horror": [],
            "Mistery": [],
            "History": [],
            "Romance": [],
            "Thriller": [],
            "Fiction": [],
            "Science Fiction": [],
            "Western": [],
            "Philosophy": [],
            "Psychology": [],
            "Literature": []
            }

		// Create a Librarianistrator resource and save it to Alexandria account storage
		let Librarianistrator <- create Librarian()
		self.account.storage.save(<- Librarianistrator, to: self.LibrarianStoragePath)
    }
}