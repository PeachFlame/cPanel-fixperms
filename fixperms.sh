#! /bin/bash
# 
# License: GNU General Public License v3.0
# See the Github page for full license and notes:
# https://github.com/PeachFlame/cPanel-fixperms
#

# Set verbose to null
verbose=""

# Print the help text
helptext () {
    tput bold
    tput setaf 2
    echo "Fix Permissions (fixperms) Script help:"
    echo "Sets file/directory permissions to match suPHP and FastCGI schemes"
    echo "USAGE: fixperms [option] [scope]"
    echo "-------"
    echo "Scope:"
    echo "--account or -a: Specify a cPanel account"
    echo "-all: Run fixperms on all cPanel accounts"
    echo "Options:"
    echo "-b: Backup firstly"
    echo "-v: Verbose output"
    echo "-h or --help: Print this screen and exit"
    tput sgr0
    exit 0
}

# Main workhorse, fix perms per account passed to it
fixperms () {

    # Get account from what is passed to the function
    account=$1
    
    # Check account against cPanel user files
    if ! grep $account /var/cpanel/users/*
    then
        tput bold
        tput setaf 1
        echo "Invalid cPanel account!"
        tput sgr0
    exit 0
    fi
    
    # Make sure account isn't blank
    if [ -z $account ]
    then
        tput bold
        tput setaf 1
        echo "Need a cPanel account!"
        tput sgr0
        helptext
    # Else, start doing work
    else

        # Get the account's homedir
        HOMEDIR=$(egrep "^${account}:" /etc/passwd | cut -d: -f6)

        # Backup if flag passed through
        if [ "$backup" = true ] ; then
            backupdate=$(date +%F)
            backuptime=$(date "+%F-%T")
            backupdir="/root/fixperms_backups/fixperms_backups_"${backupdate}""
            mkdir -p $backupdir
            echo "Backing up perms for $account"
            find $HOMEDIR -printf 'chmod %#m "%p"\n' > "${backupdir}"/backup_perms_"${account}"_"${backuptime}".sh
            echo "Backing up ownership for $account"
            find $HOMEDIR -printf 'chown %u:%g "%p"\n' > "${backupdir}"/backup_owner_"${account}"_"${backuptime}".sh
        fi

        tput bold
        tput setaf 4
        echo "(fixperms) for: $account"
        tput setaf 3
        echo "--------------------------"
        tput setaf 4
        echo "Fixing website files..."
        tput sgr0

        # Fix owner of public_html
        chown -R $verbose $account:$account $HOMEDIR/public_html

        # Fix individual files in public_html
        find $HOMEDIR/public_html -type d -exec chmod $verbose 755 {} \;
        find $HOMEDIR/public_html -type f | xargs -d$'\n' -r chmod $verbose 644
        find $HOMEDIR/public_html -name '*.cgi' -o -name '*.pl' | xargs -r chmod $verbose 755
        # Regular and Hidden files support - hidden ref: https://serverfault.com/a/156481
        # Fix hidden files and folders like .well-known/ with root or other user perms
        chown $verbose -R $account:$account $HOMEDIR/public_html/*
        chown $verbose -R $account:$account $HOMEDIR/public_html/.[^.]*
        find $HOMEDIR/* -name .htaccess -exec chown $verbose $account.$account {} \;

        tput bold
        tput setaf 4
        echo "Fixing public_html itself..."
        tput sgr0
        # Fix perms of public_html itself
        chown $verbose $account:nobody $HOMEDIR/public_html
        chmod $verbose 750 $HOMEDIR/public_html

        # Fix subdomains that lie outside of public_html
        tput setaf 3
        tput bold
        echo "--------------------------"
        tput setaf 4
        echo "Fixing any domains with a docroot outside public_html..."
        for SUBDOMAIN in $(grep -i documentroot /var/cpanel/userdata/$account/* | grep -v '.cache\|_SSL' | awk '{print $2}' | grep -v public_html)
        do
            tput bold
            tput setaf 4
            echo "Fixing sub/addon domain docroot for $SUBDOMAIN..."
            tput sgr0
            chown -R $verbose $account:$account $SUBDOMAIN;
            find $SUBDOMAIN -type d -exec chmod $verbose 755 {} \;
            find $SUBDOMAIN -type f | xargs -d$'\n' -r chmod $verbose 644
            find $SUBDOMAIN -name '*.cgi' -o -name '*.pl' | xargs -r chmod $verbose 755
            chown $verbose -R $account:$account $SUBDOMAIN
            chmod $verbose 755 $SUBDOMAIN
            find $SUBDOMAIN -name .htaccess -exec chown $verbose $account.$account {} \;
        done

        # Finished
        tput bold
        tput setaf 3
        echo "Finished! (User: $account)"
        echo "--------------------------"
        printf "\n\n"
        tput sgr0
    fi

    return 0
}

# Parses all users via cPanel's users/domains file
all () {
    for user in $(cut -d: -f1 /etc/domainusers)
    do
        fixperms $user
    done
}

# Main function, switches options passed to it
case "$1" in
    -h) helptext ;;
    --help) helptext ;;
    -v) verbose="-v" ;;
    -b) backup="true"

    case "$2" in
        -all) all ;;
        --account) fixperms "$3" ;;
        -a) fixperms "$3" ;;
        *) 
            tput bold
            tput setaf 1
            echo "Invalid option!"
            helptext
        ;;
    esac
    ;;

    -all) all ;;
    --account) fixperms "$2" ;;
    -a) fixperms "$2" ;;
    *)
        tput bold
        tput setaf 1
        echo "Invalid option!"
        helptext
    ;;
esac
