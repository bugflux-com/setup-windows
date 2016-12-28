# Bugflux setup for Windows

- [Documentation](http://bugflux.com/guide/master/getting-started/installation.html#Windows)
- [Source](https://github.com/bugflux-com/setup-windows)

## Installation

To install Bugflux run `bugflux-setup.bat`, usage:

```
bugflux-setup.bat <path_where_to_install> [port_for_bugflux] [port_for_php-cgi]
```

- `path_where_to_install` - here bugflux folder will be created and all needed files will be copied or downloaded here
- `port_for_bugflux` - this port will be used by nginx for Bugflux, default is 80
- `port_for_php-cgi` - on this port php-cgi will listen and nginx will use it to process php, default is 9123

Example:
```
bugflux-setup.bat C:\Users\John 3010 9124
```


## Run server

In installation folder you should see `run_bugflux.bat` file. Run it to start bugflux. Your server is available at `localhost:<port_for_bugflux>`.

By default there's available root account with credentials:
```
email: root@bugflux.com
password: secret
```

We recommend you to change root password and email.


## Stop server

In installation folder you should see `shutdown_bugflux.bat` file. Run it to stop bugflux


## FAQ

> What does the bugflux-setup.bat do?

It downloads php and nginx and configurates them. It also downloads composer to install depedencies for bugflux. It creates database and fills it with necessary data.

---

> What if I want to use bugflux with my own php or nginx server?

All you need is `bugflux_app.zip` - public folder should be set as root for application.

Then run below commands in terminal:
```
composer install
// Setup configuration...
php artisan migrate --seed

npm install
npm run prod
```

---

> What if I don't want to use SQLite or nginx?

You can configure everything manually. Visit our documentation website or contact us for more informations.

