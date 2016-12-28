# Bugflux setup for Windows

- [Documentation](http://bugflux.com/guide/master/getting-started/installation.html#Windows)
- [Contributing](http://bugflux.com/guide/master/for-developers/contributing.html)

## Preparing server setup

- Download [server source](https://github.com/bugflux-com/server)
- Run `npm install` and `npm run prod`
- Delete `node_modules` directory
- Zip files as a `setup/bugflux_app.zip` (zip root should contain all project files and directories)
- Replace zipped `.env.example` with the one provided in this repo
- Setup folder can be zipped and uploaded to server as installer