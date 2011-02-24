## Welcome to Jester !

This little app is a game to handle Github v2 api and display a simple dashboard of a user and his organization repositories issues (open ones at the moment). it also display the comments and the labels with links to the issue and the labels.

### How to run it

First you need a config file `config/settings/development.yml`

    github:
        user: your_user
        token: your_token
        organization: your_organization

At the moment you *need* to have an organization. If you don't, well you gonna need to change the code, send a pull request if you do.

Then you can run `rake hub_pull:update` which should take care of everything : pull your repositories, their issues and issues comments. But .. keep in mind it will pull a big load of stuff from github at once, so they might no be happy and it might not work.

Solution : have some jquery trigger the pulls when needed. It's also needed to handle the updates.

Note : after the first complete pull, hashes are used to check if something is already in, but still I need to find a clever way to do that and only pull stuff when needed and only what's needed.

### Licence

MIT, see LICENCE file.