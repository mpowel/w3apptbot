# Heroku Template Application 

A quick start Sinatra project that can be deployed to Heroku easily.

To use this:

__Initial Setup__

1. Create a new project folder on your own computer. 
2. Copy in the code from this folder.
3. `bundle install` in the termain window to set up dependencies (change directory into it.)
3. Using GitHub Desktop, add it to a new git repo (see [Preparing your project](https://github.com/daraghbyrne/onlineprototypes2016repo/blob/master/guides/deploying/deploying-to-heroku.md#preparing-your-app))
4. Either create a file called `.gitignore` in your project's folder or open your repository in GitHub Desktop application, Choose `Repository` in the menu, and then `Repository Settings`; Choose the second tab which says `Ignored files` and add the following to it

	````
	/db/*.db
	/db/*.db-journal
	/db/*.sqlite3
	/db/*.sqlite3-journal

	/tmp
	/log/*log

	.env
	````

5. Edit the `.env` file and add any keys you'll need for the project (API info, etc.)
5. In Git, Commit your changes and sync to master.
6. Open a terminal window, change into your project folder and type `heroku create`
7. Add config vars (same as `.env`) to heroku 
	a. via the online dashboard, select the app, click the Settings tab and press `Reveal Config Vars` to edit
	b. via the terminal window, using: `heroku config:set VARIABLE_NAME=VARIABLE_VALUE`
7. Add the add on for a Postgres database to your Heroku app: `heroku addons:create heroku-postgresql`
8. Deploy using `git push heroku master` in the terminal
9. If you have migrations in your project, do them now: `heroku run rake db:migrate `
10. If you have seeds to run for your project, do them now: `heroku run rake db:seed `
10. Launch your app in the browser: `heroku open`

__After making changes to your project__

1. If you've changed the gem file: `bundle install` in terminal
2. In Git, Commit your changes and sync to master. Wait until it's synced... 
3. Deploy using `git push heroku master` in the terminal
4. If you have new migrations in your project, do them now: `heroku run rake db:migrate `
5. If you have new seeds to run for your project, do them now: `heroku run rake db:seed `
