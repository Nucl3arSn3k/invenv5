# invenv6

Inventory controll

## Installation

TODO: Write installation instructions here

## Usage
install kemal
run `shards install`

run `make`

run `nim c --cc:gcc --app:lib --noMain --header --out:libloginhandle.so --passL:"-lcurl" login_codegen.nim`

run `crystal build --release src/invenv6.cr   --link-flags="-L/app/src/codegen -Wl,-rpath,/app/src/codegen"` to compile with linked C functionality.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/invenv6/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Nucl3arSn3k](https://github.com/your-github-user) - creator and maintainer
