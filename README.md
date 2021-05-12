# Codea Community Project Repository
Repository of projects created by the community of the iOS app [Codea](https://codea.io)

# Getting Started
To get started using the repository, download the [WebRepo project](https://github.com/steppers/codea-community-repo/releases) to your iOS device and run it from within Codea.

Simple as that! You should now have access to many user created Codea projects available to Download, Run & Edit all from within Codea itself.

To top it all off, if there's an update to the WebRepo project, it'll update itself automatically!

To download a project, simply tap it. The title will turn purple to let you know it's downloading, then green when it's finished.

To run a project that's been downloaded, either tap it in the WebRepo project or directly in Codea like any other project.

![iPad](https://github.com/steppers/codea-community-repo/raw/main/screenshots/1.0_ipad.jpg)

# Extra things
Deleting a project can only be done from outside of the WebRepo project currently but there are plans to add the functionality in the future.

# Submitting a project
Please ensure you have set an icon for your project if you do not wish me to do it for you.

To submit a project and have it added to the repo, please export your project from within Codea to generate a .zip file.

Once you have your project's zip file please do one of the following:
 - Submit a pull request containing the file. Someone with write access to the repository should be able to take it from there. (Easiest for large projects > 10MB)
 - Send me a direct message on [Codea.io](https://codea.io/talk/profile/36722/Steppers) and we can take it from there.

You'll also need to provide the following:
 - Name as you wish for the project to appear in the project browser
 - Short description (~6-8 words)
 - Author(s) (Visible in the WebRepo App)
 - Version string
 - Is the project a library (Can it be run standalone?)
 - Link to Codea.io forum discussion related to the project
 - A LICENSE.txt file if you wish one to be included with your project

As only I currently have write access to the repository please be patient when it comes to submitting apps. I hope to bring others on board too if this gets enough interest.

Please note that attempts to submit illegal, malicious, unethical or innappropriate content will be ignored.


# Adding a project (For Contributors)
If you have any questions do feel free to send me a message at [Codea.io](https://codea.io/talk/messages/inbox)

### Preparing the .codea bundle
- Please ensure the data requested above has been provided.
- Extract the zip file to reveal the .codea project. This can be opened as a folder in many applications to view the contents of the bundle (Textastic & Working Copy can do this).
- Add the additional data provided by the user to the project's Info.plist file (see other projects for an example).
- Ensure a project icon has been provided in the .codea bundle and that the corresponding entry in Info.plist is set correctly.

### Testing the .codea bundle
Do not commit untested projects to the 'main' branch as this will be immediately available to users.
- Commit the .codea bundle to the 'sub' branch, making sure the branch is up to date with 'main' beforehand
- In Codea open your copy of the WebRepo project and change the value of `GITHUB_BRANCH` on the 'Main' tab to `"sub"`. This should disable autoupdates for your local copy and direct all requests to the submission testing branch.
- When running the WebRepo project the new submission should now be available to download. Download it and ensure the project does not crash when launched. If assets are missing you may be missing the downloadable asset packs in Codea.
- If all is well the 'sub' branch can then be merged into 'main' to make the project available to all users.
- You can then swap your local copy of WebRepo back to using `GITHUB_BRANCH = "main"`
