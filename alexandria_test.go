package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"testing"

	. "github.com/bjartek/overflow/v2"
	"github.com/fatih/color"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// ReadFile reads a text file and returns an array of paragraphs
func ReadFile(filename string) ([]string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var content string
	scanner := bufio.NewScanner(file)

	// Read file content line by line
	for scanner.Scan() {
		content += scanner.Text() + "\n"
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	// Split the content into paragraphs
	// Assuming paragraphs are separated by one or more newlines
	rawParagraphs := strings.Split(content, "\n")
	paragraphs := make([]string, 0, len(rawParagraphs))

	for _, paragraph := range rawParagraphs {
		trimmed := strings.TrimSpace(paragraph)
		if trimmed != "" {
			paragraphs = append(paragraphs, trimmed) // Add non-empty paragraphs
		}
	}

	return paragraphs, nil
}

func TestFullFlow(t *testing.T) {
	// Full cover test suite for the whole app Flow
	// Specify the path to your JavaScript file
	filePath := "books/chapters/example.js"

	paragraphs, err := ReadFile(filePath)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println("Paragraphs:")
	for i, paragraph := range paragraphs {
		fmt.Printf("Paragraph %d: %s\n", i+1, paragraph)
	}

	o, err := OverflowTesting()
	require.NoError(t, err)
	require.NotNil(t, o)
	assert.NoError(t, err)

	color.White("STARTING Alexandria Library FLOW")
	color.Green("GREEN transactions are meant to SUCCEED")
	color.Red("Red transactions are meant to FAIL")
	// initialize the contract and setups
	color.Green("Admin will add a book directly to the library")
	// Add a book
	o.Tx("Admin/add_book",
		WithSigner("account"),
		WithArg("title", "The Awakening"),
		WithArg("author", "Kate Chopin"),
		WithArg("genre", "Feminist Literature"),
		WithArg("edition", "First Edition"),
		WithArg("summary", "Kate Chopin’s novel, The Awakening, published in 1899, tells the story of Edna Pontellier, a married woman who longs for independence and self-discovery. Set in 19th-century New Orleans, the novel explores themes of identity, autonomy, and the limitations imposed on women during that era."),
	).AssertSuccess(t).Print()
	o.Script("get_book",
		WithArg("bookTitle", "The Awakening"),
	).Print()
	o.Script("get_books_by_genre",
		WithArg("genre", "Feminist Literature"),
	).Print()
	o.Script("get_genres").Print()
	o.Script("get_books_by_author",
		WithArg("author", "Kate Chopin"),
	).Print()
	// Add a chapter title to a book
	o.Tx("Admin/add_chapter_name",
		WithSigner("account"),
		WithArg("bookTitle", "The Awakening"),
		WithArg("chapterTitle", "I"),
	).AssertSuccess(t).Print()
	// Add a chapter to a book
	o.Tx("Admin/add_chapter",
		WithSigner("account"),
		WithArg("bookTitle", "The Awakening"),
		WithArg("chapterTitle", "I"),
		WithArg("index", 1),
		WithArg("paragraphs", paragraphs),
	).AssertSuccess(t).Print()
	o.Script("get_book",
		WithArg("bookTitle", "The Awakening"),
	).Print()
	// Add a book to your favorites
	o.Tx("add_favorite",
		WithSigner("account"),
		WithArg("title", "The Awakening"),
	).AssertSuccess(t).Print()

	// Now a Librarian will attempt to submit a chapter to a book
	// Add a chapter to a book
	o.Tx("Librerian/submit_chapter",
		WithSigner("bob"),
		WithArg("bookTitle", "The Awakening"),
		WithArg("chapterTitle", "II"),
		WithArg("index", 2),
		WithArg("paragraphs", paragraphs),
	).AssertSuccess(t).Print()

}
