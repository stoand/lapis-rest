# Lua REST Server for Ember Data
**Using [Nginx](http://nginx.org/en),  [OpenResty](http://openresty.org/) and the [Lapis](http://leafo.net/lapis/) Framework**

*Instructions for Ubuntu Linux*

## Running the Server

### Installing the Dependencies
* `sudo apt-get install luarocks nginx`
* [Install OpenResty](http://openresty.org/#Installation)
* `sudo luarocks install lapis`
### Starting the Server
* `git clone git@github.com:Arubaruba/lapis-rest.git`
* `cd lapis-rest`
* `lapis server`

## Testing 

### Installing the Testing Framework
* `sudo apt-get install libssl-dev`
* `sudo luarocks install luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu/`
* `sudo luarocks install busted`

### Running the Tests
* From inside the Project Directory run: `busted spec`
