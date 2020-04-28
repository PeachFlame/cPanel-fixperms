#! /bin/bash
# 
# License: GNU General Public License v3.0
# See the Github page for full license and notes:
# https://github.com/PeachFlame/cPanel-fixperms
#

# Set verbose to null
verbose=""


#Print the help text
helptext () {
    tput bold
    tput setaf 2
    echo "Fix perms script help:"
    echo "Sets file/directory permissions to match suPHP and FastCGI schemes"
    echo "USAGE: fixperms [options] -a account_name"
    echo "-------"
    echo "Options:"
    echo "-h or --help: print this screen and exit"
    echo "-v: verbose output"
    echo "-all: run on all cPanel accounts"
    echo "--account or -a: specify a cPanel account"
    tput sgr0
    exit 0
}

# Main workhorse, fix perms per account passed to it
fixperms () {

  #Get account from what is passed to the function
  account=$1

  #Check account against cPanel users file
  if ! grep $account /var/cpanel/users/*
  then
    tput bold
    tput setaf 1
    echo "Invalid cPanel account"
    tput sgr0
    exit 0
  fi

  #Make sure account isn't blank
  if [ -z $account ]
  then
    tput bold
    tput setaf 1
    echo "Need an account name!"
    tput sgr0
    helptext
  #Else, start doing work
  else

    #Get the account's homedir
    HOMEDIR=$(egrep "^${account}:" /etc/passwd | cut -d: -f6)

    tput bold
    tput setaf 4
    echo "Fixing perms for $account:"
    tput setaf 3
    echo "------------------------"
    tput setaf 4
    echo "Fixing website files...."
    tput sgr0
    
    #Fix individual files in public_html
    find $HOMEDIR/public_html -type d -exec chmod $verbose 755 {} \;
    find $HOMEDIR/public_html -type f | xargs -d$'\n' -r chmod $verbose 644
    find $HOMEDIR/public_html -name '*.cgi' -o -name '*.pl' | xargs -r chmod $verbose 755
    chown $verbose -R $account:$account $HOMEDIR/public_html/*
    find $HOMEDIR/* -name .htaccess -exec chown $verbose $account.$account {} \;

    tput bold
    tput setaf 4
    echo "Fixing public_html...."
    tput sgr0
    #Fix perms of public_html itself
    chown $verbose $account:nobody $HOMEDIR/public_html
    chmod $verbose 750 $HOMEDIR/public_html

    #Fix subdomains that lie outside of public_html
    tput setaf 3
    tput bold
    echo "------------------------"
    tput setaf 4
    echo "Fixing any domains with a document root outside of public_html...."
    for SUBDOMAIN in $(grep -i documentroot /var/cpanel/userdata/$account/* | grep -v '.cache\|_SSL' | awk '{print $2}' | grep -v public_html)
    do
      tput bold
      tput setaf 4
      echo "Fixing sub/addon domain document root $SUBDOMAIN...."
      tput sgr0
      find $SUBDOMAIN -type d -exec chmod $verbose 755 {} \;
      find $SUBDOMAIN -type f | xargs -d$'\n' -r chmod $verbose 644
      find $SUBDOMAIN -name '*.cgi' -o -name '*.pl' | xargs -r chmod $verbose 755
      chown $verbose -R $account:$account $SUBDOMAIN
      chmod $verbose 755 $SUBDOMAIN
      find $SUBDOMAIN -name .htaccess -exec chown $verbose $account.$account {} \;
    done

  #Finished
    tput bold
    tput setaf 3
    echo "Finished!"
    echo "------------------------"
    printf "\n\n"
    tput sgr0
  fi

  return 0
}

#Parses all users through cPanel's users file
all () {
    for user in $(cut -d: -f1 /etc/domainusers)
    do
  fixperms $user
    done
}

#Main function, switches options passed to it
case "$1" in

    -h) helptext
  ;;
    --help) helptext
      ;;
    -v) verbose="-v"

  case "$2" in

    -all) all
           ;;
    --account) fixperms "$3"
         ;;
    -a) fixperms "$3"
        ;;
    *) tput bold
           tput setaf 1
       echo "Invalid Option!"
       helptext
       ;;
  esac
  ;;

    -all) all
    ;;
    --account) fixperms "$2"
          ;;
    -a) fixperms "$2"
  ;;
    *)
       tput bold
       tput setaf 1
       echo "Invalid Option!"
       helptext
       ;;
esac
