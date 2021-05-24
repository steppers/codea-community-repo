# Codea Community Project Repository
Repository of projects created by the community of the iOS app [Codea](https://codea.io)

# Getting Started
To get started using the repository, download the [WebRepo project](https://github.com/steppers/codea-community-repo/releases) to your iOS device and run it from within Codea.

Simple as that! You should now have access to many user created Codea projects available to Download, Run & Edit all from within Codea itself.

- To download a project, simply tap it. The title will turn purple to let you know it's downloading, then green when it's finished.
- To run a project that's been downloaded, either tap it in the WebRepo project or run it in Codea like any other project.

To top it all off, if there's an update to the WebRepo project, it'll update itself automatically!

![iPad](https://github.com/steppers/codea-community-repo/raw/main/screenshots/1.2_ipad.PNG)

# Submitting a project
Please ensure you have set an icon for your project if you do not wish me to do it for you.

To submit a project we require a .zip of the project (in Codea, press and hold on project -> export). 

Please submit your project using the [Google form here](https://forms.gle/X7entVzHGQjB7kYx6) if you do not mind sharing the name associated with your Google account with me (Only me, and only the name so nothing to worry about). Projects uploaded using this form should be < 100MB currently but if there is ever demand I can increase that to 1GB.

If this is a problem please use the [alternative form](https://forms.gle/ZvTWZ24y4rmj4HuD7) and provide a link where I can download the project from (Google Drive, Dropbox, etc.)

Once we have everything we’ll test the project to make sure everything works within the WebRepo project and if all is well you should see the project appear in the WebRepo browser in no time!

Please note that attempts to submit illegal, malicious, unethical or innappropriate content will be ignored.

![iPad](https://github.com/steppers/codea-community-repo/raw/main/screenshots/1.2_ipad2.PNG)

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
