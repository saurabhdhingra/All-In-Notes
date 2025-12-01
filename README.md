# All-In-Notes: Rich Text Note-Taking for iOS

**All-In-Notes** is a modern iOS application designed for effortless and organized note-taking. Go beyond plain text—add **rich formatting**, utilize powerful **tagging**, and instantly **search** across your notes and tags. Experience note-taking like never before with smooth, engaging **Swift animations**!

https://github.com/user-attachments/assets/55f16411-37a3-4457-bcef-4ab36f26edc5


---

## Key Features

* **Rich Text Editing:** Format your notes using various styles, including **bold**, *italics*, lists, and more, to make your information stand out and easy to read.
* **Intelligent Tagging:** Easily **tag** your notes with relevant keywords for quick categorization and retrieval.
* **Powerful Search:** Instantly search your entire note library based on **content** or specific **tags**.
* **Elegant UI/UX:** Enjoy a clean, intuitive interface complemented by custom, delightful animations.
* **Custom Swift Animations:** Delightful **Stacked Card** transitions and intricate **Custom Path** animations enhance the user experience, making interaction smooth and engaging.

---

## Technical Highlights

NotesPlus is built entirely in **Swift** and leverages several modern iOS frameworks and techniques:

* **SwiftUI:** Used for building the entire user interface.
* **SwiftData:** Used for persistent data storage of notes and tags.
* **AttributedString (or relevant Rich Text API):** Handles the robust Rich Text editing capabilities.
* **Custom Drawing:** The signature animations utilize **`Shape`** and **`Path`** drawing in SwiftUI, combined with **`withAnimation`** and **`Transaction`** for the unique transitions and effects (Stacked Cards).

---

## Installation and Setup

To run NotesPlus on your local machine, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone [Your Repository URL]
    ```
2.  **Open in Xcode:**
    Navigate to the project directory and open `Planner.xcodeproj` (or the workspace file if applicable).
3.  **Select a Device:**
    Choose a simulator or a physical device running **iOS 17.0+** (or your target OS).
4.  **Run:**
    Press **Cmd + R** or click the **Run** button to build and install the app.

---

## Future Enhancements

* Cloud synchronization (e.g., iCloud or Firebase).
* Markdown support.
* Note folders/hierarchy.
* Adding imageas
