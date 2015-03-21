# cPanel-fixperms
A script to fix permissions and ownership, on files and directories, for cPanel accounts.

## More Info
Ever needed just to quickly 'fix' the permissions or ownership for your files in a regular cPanel account? This is the script for you. There is a staggering number of people using cPanel out there, and this script will help every cPanel user quickly recover from self-made permission mistakes or allow you to be lazy when setting permissions when uploading new scripts (ex: Wordpress).

It safely steps through the file structure only in a particular user, and sets folders to be owned by the user, and files to have cPanel-recommended permissions.

It is safe to run, and I would run it in a heart-beat as a general 'fix my errors' fix.

Note: This is inteded for non-DSO servers (ex: FastCGI, suPHP, etc...). You CAN run this on a DSO box, but just know that things such as Wordpress uploads won't work. You'll have to manually set some folders to be owned by the user "nobody".

## Instructions
You can read more info on my site here: http://boomshadow.net/tech/fixes/fixperms-script/

### Fixperms - for one single user

To get the fixperms script, simply wget the file from GitHub and make sure it's executable:

```bash
wget https://raw.githubusercontent.com/PeachFlame/cPanel-fixperms/master/fixperms.sh
chmod +x fixperms.sh
```

Then, run it (with ROOT permissions) while using the 'a' flag to specify a particular cPanel user:
```bash
sudo sh ./fixperms.sh -a USER-NAME
```
It does not matter which directory you are in when you run fixperms. You can be in the user’s home directory, the server root, etc... The script will not affect anything outside of the particular user’s home folder.

### Fixperms - for all of the users
If you would like fix the permissions for every user on your cPanel server, simply use the '-all' option:

```bash
sudo sh ./fixperms.sh -all
```

### Verbosity of Fixperms
By default, the script runs in a 'quiet' mode with minimal display. However, if you’re like me, you may want to see everything that is happening. You can turn on verbosity and have the script print to the screen everything that is being changed. I find this extremely useful when fixing large accounts that have many files. You can watch the changes as a sort of 'progress bar' of completion. The '-v' option can be used per account or with all accounts.

#### For one single account ####
```bash
sudo sh ./fixperms.sh -v -a USER-NAME
```

#### For all accounts ####
```bash
sudo sh ./fixperms.sh -v -all
```

### Getting Help
You can run fixperms with the '-h' or '--help' flags in order to see a help menu.

### Adding Fixperms to your bin
I host numerous websites for friends and family, who will routinely make mistakes in regards to file permissions. It's understandable; they're not tech people. I will need to fix their permissions for them pretty frequently on my servers so I opted to put the fixperms script in all my servers' bin folders.

```bash
sudo mv fixperms.sh /usr/bin/
```

## History
This script is the spiritual recreation of a cPanel 'fixperms' script originally written by my good friend, Dean Freeman. It was something he developed while we were working together doing tech support at a web hosting company.

The fixperms script was so helpful, I wanted to share it with the world. It had been many years since the first version was written, so it needed some updating. I contracted my other friend, Colin R., to help me rewrite it for the masses, with Dean's blessing.

Colin is a beast and a "pirate" when it comes to coding, and I thank him for everything he did. This newest rendition was developed while we were both working tech support at a different hosting company: ServInt.