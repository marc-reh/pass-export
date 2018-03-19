# pass-export
A pass extension that exports passwords from the password store

## Description `pass export` extends the pass utility with an export
command. `pass export` exports passwords specified in an export file
to a target repository. If the target repository does not exist, `pass
export` asks whether it should create it (as a bare git repository).

The new password store can for example be imported on an Android phone
with the Password Store app. The use of `pass export` allows the
transfer of only a selection of passwords, in contrast to cloning the
full password store.

## Usage

```
pass export 1.0

Usage:
    pass export [-h] [-v] [-V] export-name target-repo
        Export passwords specified in export-name.export to target-repo

        export-name.export is a user-provided file in ~/.password-store
        (unless this default is overridden by the environment variable
        PASSWORD_STORE_DIR, see pass(1) man page).

        export-name.export lists passwords or directories to be exported,
        e.g.:

        Email/my_email.com
        Banking

        A single dot ('.') specifies the export of all passwords from the
        password store.

        At the moment, pass-export's only functionality is to export
        specified passwords to a git repository target-repo. If target-repo
        does not exist, pass-export asks whether it should create it (as a
        bare repository).

    Options:
        -h, --help    Print this help message and exit
        -v, --verbose Show all git output
        -V, --version Show version information and exit
```

See also `man pass-export`.

## Example

```
List existing passwords in store:

     $ pass
     Password Store
     |‐‐ Email
     |   |‐‐ my_email.com
     |   ‐‐‐ another_email.com
     ‐‐‐ Banking
     |   |‐‐ big_money.com
     |   ‐‐‐ credit_card
     ‐‐‐ Shopping
         |‐‐ super_shop.com
         |‐‐ books.com
         ‐‐‐ my_store.com

Make a file android.export in ~/.password‐store with the following con‐
tent:

     Email/my_email.com
     Banking

Export passwords to ~/androidpasswords.git:

     $ pass export android ~/androidpasswords.git

~/androidpasswords.git now contains the password Email/my_email.com and
all  passwords  under  Banking.  This  new  password  store  can now be
imported on an Android phone with the Password Store  app.  The  target
repository can be exported to repeatedly.
```

## Installation

**OS X**

```sh
git clone https://github.com/marc-reh/pass-export/
cd pass-export
make install PREFIX=/usr/local
```

### Contribution
Feedback, contributors, pull requests are all very welcome.

## License
MIT License

Copyright (c) 2018 Marc Rehmsmeier

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
