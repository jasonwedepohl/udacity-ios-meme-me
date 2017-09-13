# MemeMe

MemeMe is an app for iOS, and one of the projects composing Udacity's iOS nanodegree. It allows the user to create image memes and share them.

The core requirements for this app:
- From the landing page, the user can tap Add ("+") to go to the meme editor.
- In the meme editor, the user can select a photo from the camera or gallery and caption it with top and bottom text.
- The user may share the meme using Apple's standard activity selector, which gives them several ways to share.
- Shared memes are saved in memory and appear on the landing page.
- Using a tab bar at the bottom of the landing page, the user may select to view the shared memes in a list or grid.
- Tapping a shared meme on the landing page takes the user to a detail view where they can get a closer look at the meme.
- The UI must adapt to the various iOS device screen sizes and to device orientation changes.

This version of the app fulfils those requirements and adds some features:
- The classic image meme font, Impact, is bundled with the app and used in the meme editor.
- Swipe-to-delete: when viewing shared memes as a list, the user can swipe a row to the left to reveal a Delete button, allowing them to delete the meme.
- Edit existing memes: After tapping a shared meme on the landing page and opening the meme detail view, the user can tap "Edit" (top right of screen) to open the meme in the meme editor view. They can edit the top and bottom text and share it again. After sharing, the meme editor will close to reveal the changed meme in the meme detail view.
