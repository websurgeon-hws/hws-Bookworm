//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Book.entity(),
                  sortDescriptors: [
        NSSortDescriptor(keyPath: \Book.title, ascending: true),
        NSSortDescriptor(keyPath: \Book.author, ascending: true)
    ])
    
    var books: FetchedResults<Book>

    @State private var showingAddScreen = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(books, id: \.self) { book in
                    NavigationLink(destination: DetailView(book: book)) {
                        EmojiRatingView(rating: book.rating)
                            .font(.largeTitle)

                        VStack(alignment: .leading) {
                            Text(book.title ?? "Unknown Title")
                                .font(.headline)
                            Text(book.author ?? "Unknown Author")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationBarTitle("Bookworm")
            .navigationBarItems(leading: EditButton(),
                                trailing: Button(action: {
                self.showingAddScreen.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddScreen) {
                AddBookView().environment(\.managedObjectContext, self.moc)
            }
        }
    }
    
    func deleteBooks(at offsets: IndexSet) {
        for offset in offsets {
            // find this book in our fetch request
            let book = books[offset]

            // delete it from the context
            moc.delete(book)
        }

        // save the context
        try? moc.save()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let moc: NSManagedObjectContext = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
        let book1 = Book(context: context)
        book1.title = "Test book 1"
        book1.author = "Test author 1"
        book1.genre = "Fantasy"
        book1.rating = 4
        book1.review = "This was a great book; I really enjoyed it."

        let book2 = Book(context: context)
        book2.title = "Test book 2"
        book2.author = "Test author 2"
        book2.genre = "Horror"
        book2.rating = 2
        book2.review = "This was an ok book; I slightly enjoyed it."
        
        return context
    }()

    static var previews: some View {
        
        
        return ContentView()
            .environment(\.managedObjectContext, moc)
    }
}
