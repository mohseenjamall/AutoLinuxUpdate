#!/bin/bash
# Enhanced Linux Update Tool
# This tool performs a complete system update with error recovery capabilities

# Detect operating system
echo "Checking operating system..."
OS=""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
elif [ -f /etc/debian_version ]; then
    OS="debian"
elif [ -f /etc/fedora-release ]; then
    OS="fedora"
elif [ -f /etc/centos-release ]; then
    OS="centos"
elif [ -f /etc/arch-release ]; then
    OS="arch"
else
    OS=$(uname -s)
fi

# Display startup message
echo "========================================"
echo "  Enhanced Linux Update Tool with Error Recovery"
echo "========================================"
echo "Detected operating system: $OS"
echo "Starting comprehensive update process..."
echo "========================================"

# Function to print steps
print_step() {
    echo ""
    echo ">> $1"
    echo "----------------------------------------"
}

# Function to check if system is already up to date (Debian-based)
check_if_up_to_date_debian() {
    print_step "Checking if system is already up to date"
    
    # Capture apt update output
    UPDATE_OUTPUT=$(sudo apt-get update 2>&1)
    
    # Check if there are any updates available
    UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l)
    
    if [ "$UPGRADABLE" -eq 0 ]; then
        echo "Your system is already up to date! No packages need updating."
        return 0
    else
        echo "Found $UPGRADABLE package(s) that can be upgraded."
        return 1
    fi
}

# Function to check if system is already up to date (Fedora/RHEL)
check_if_up_to_date_fedora() {
    print_step "Checking if system is already up to date"
    
    # Check if there are any updates available
    UPDATES_AVAILABLE=$(sudo dnf check-update -q | grep -v "^$" | wc -l)
    
    if [ "$UPDATES_AVAILABLE" -eq 0 ]; then
        echo "Your system is already up to date! No packages need updating."
        return 0
    else
        echo "Found $UPDATES_AVAILABLE package(s) that can be upgraded."
        return 1
    fi
}

# Function to check if system is already up to date (Arch)
check_if_up_to_date_arch() {
    print_step "Checking if system is already up to date"
    
    # Check if pacman sees any updates
    sudo pacman -Sy > /dev/null 2>&1
    UPDATES_AVAILABLE=$(pacman -Qu | wc -l)
    
    if [ "$UPDATES_AVAILABLE" -eq 0 ]; then
        echo "Your system is already up to date! No packages need updating."
        
        # Check AUR packages too if available
        if command -v paru &> /dev/null; then
            AUR_UPDATES=$(paru -Qua | wc -l)
            if [ "$AUR_UPDATES" -eq 0 ]; then
                echo "AUR packages are also up to date."
            else
                echo "Found $AUR_UPDATES AUR package(s) that can be upgraded."
                return 1
            fi
        elif command -v yay &> /dev/null; then
            AUR_UPDATES=$(yay -Qua | wc -l)
            if [ "$AUR_UPDATES" -eq 0 ]; then
                echo "AUR packages are also up to date."
            else
                echo "Found $AUR_UPDATES AUR package(s) that can be upgraded."
                return 1
            fi
        fi
        
        return 0
    else
        echo "Found $UPDATES_AVAILABLE package(s) that can be upgraded."
        return 1
    fi
}

# Function to fix Debian/Ubuntu/Kali-specific dpkg interruption errors
fix_dpkg_interruption() {
    print_step "Checking for interrupted dpkg processes"
    
    # Check if dpkg was interrupted
    if sudo apt-get update 2>&1 | grep -q "dpkg was interrupted"; then
        echo "Found interrupted dpkg process, fixing..."
        sudo dpkg --configure -a
        return $?
    fi
    
    return 0
}

# Function to fix repository mirror issues in Debian-based systems
fix_mirror_issues() {
    print_step "Checking for repository mirror issues"
    
    # Run apt update and capture any mirror errors
    MIRROR_ERROR=$(sudo apt-get update 2>&1)
    
    # Check for common mirror connection errors
    if echo "$MIRROR_ERROR" | grep -q "Failed to fetch\|Could not connect\|Cannot initiate the connection\|Connection failed\|Network is unreachable"; then
        echo "Detected mirror connection issues. Attempting to fix..."
        
        # Determine if this is Kali Linux
        if [ "$OS" = "kali" ]; then
            echo "Switching to main Kali repository mirror..."
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d%H%M%S)
            echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list
            echo "Mirror has been changed to the main Kali repository"
        else
            # For other Debian-based distributions
            if command -v apt-mirror-updater &> /dev/null; then
                echo "Using apt-mirror-updater to find the fastest mirror..."
                sudo apt-mirror-updater -i
            else
                # Fallback option for Ubuntu/Debian
                echo "Switching to main repository..."
                if [ "$OS" = "ubuntu" ]; then
                    sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d%H%M%S)
                    echo "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse" | sudo tee /etc/apt/sources.list
                elif [ "$OS" = "debian" ]; then
                    sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d%H%M%S)
                    echo "deb http://deb.debian.org/debian $(lsb_release -cs) main contrib non-free" | sudo tee /etc/apt/sources.list
                fi
            fi
        fi
        
        # Update again after changing mirrors
        echo "Updating package lists with new mirror..."
        sudo apt-get update
        return $?
    fi
    
    return 0
}

# Function executed after update completion
cleanup() {
    print_step "Cleaning temporary files and removing unused packages"
    case $OS in
        "ubuntu"|"debian"|"linuxmint"|"pop"|"elementary"|"zorin"|"kali")
            sudo apt autoremove -y
            sudo apt clean
            ;;
        "fedora"|"centos"|"rhel")
            sudo dnf autoremove -y
            sudo dnf clean all
            ;;
        "arch"|"manjaro"|"endeavouros")
            sudo pacman -Sc --noconfirm
            # Optional: Remove orphaned packages on Arch systems
            if command -v paru &> /dev/null; then
                sudo paru -c
            elif command -v yay &> /dev/null; then
                sudo yay -Yc
            fi
            ;;
        "opensuse")
            sudo zypper clean
            ;;
        *)
            echo "No specific cleanup process for your operating system"
            ;;
    esac
}

# First, check internet connectivity
check_internet

# Update based on operating system type
case $OS in
    "ubuntu"|"debian"|"linuxmint"|"pop"|"elementary"|"zorin"|"kali")
        # Fix any interrupted dpkg processes first
        fix_dpkg_interruption
        
        print_step "Updating package lists"
        UPDATE_OUTPUT=$(sudo apt-get update 2>&1)
        
        # Check for mirror issues
        if echo "$UPDATE_OUTPUT" | grep -q "Failed to fetch\|Could not connect\|Cannot initiate the connection\|Connection failed\|Network is unreachable"; then
            echo "Mirror connection issues detected, attempting to fix..."
            fix_mirror_issues
        fi
        
        # Check if system is already up to date
        if check_if_up_to_date_debian; then
            print_step "System Status"
            echo "Congratulations! Your system is completely up to date."
            echo "No further updates needed at this time."
            cleanup
            exit 0
        fi
        
        # Try update again after fixing potential issues
        print_step "Updating package lists (second attempt if needed)"
        sudo apt-get update
        
        # Handle packages with --fix-missing if needed
        print_step "Updating installed packages"
        if ! sudo apt-get upgrade -y; then
            echo "Error during upgrade, attempting with --fix-missing"
            sudo apt-get upgrade --fix-missing -y
        fi
        
        print_step "Updating entire system"
        if ! sudo apt-get dist-upgrade -y; then
            echo "Error during dist-upgrade, attempting with --fix-missing"
            sudo apt-get dist-upgrade --fix-missing -y
        fi
        
        print_step "Updating Snap if available"
        if command -v snap &> /dev/null; then
            sudo snap refresh
        fi
        
        print_step "Updating Flatpak if available"
        if command -v flatpak &> /dev/null; then
            sudo flatpak update -y
        fi
        ;;
        
    "fedora"|"centos"|"rhel")
        # Check if system is already up to date
        if check_if_up_to_date_fedora; then
            print_step "System Status"
            echo "Congratulations! Your system is completely up to date."
            echo "No further updates needed at this time."
            cleanup
            exit 0
        fi
        
        print_step "Updating all packages"
        sudo dnf update -y
        
        print_step "Updating Flatpak if available"
        if command -v flatpak &> /dev/null; then
            sudo flatpak update -y
        fi
        ;;
        
    "arch"|"manjaro"|"endeavouros")
        # Check if system is already up to date
        if check_if_up_to_date_arch; then
            print_step "System Status"
            echo "Congratulations! Your system is completely up to date."
            echo "No further updates needed at this time."
            cleanup
            exit 0
        fi
        
        print_step "Updating database and packages"
        sudo pacman -Syu --noconfirm
        
        print_step "Updating AUR if available"
        if command -v paru &> /dev/null; then
            paru -Sua --noconfirm
        elif command -v yay &> /dev/null; then
            yay -Sua --noconfirm
        fi
        
        print_step "Updating Flatpak if available"
        if command -v flatpak &> /dev/null; then
            sudo flatpak update -y
        fi
        ;;
        
    "opensuse")
        print_step "Updating system"
        sudo zypper refresh
        
        # Simple check for updates
        if [ "$(sudo zypper list-updates | grep -c "No updates found")" -eq 1 ]; then
            print_step "System Status"
            echo "Congratulations! Your system is completely up to date."
            echo "No further updates needed at this time."
            cleanup
            exit 0
        fi
        
        sudo zypper update -y
        
        print_step "Updating Flatpak if available"
        if command -v flatpak &> /dev/null; then
            sudo flatpak update -y
        fi
        ;;
        
    *)
        echo "Sorry, your operating system wasn't recognized or is not supported"
        echo "Supported operating systems: Ubuntu, Debian, Linux Mint, Fedora, CentOS, Arch Linux, Manjaro, openSUSE"
        exit 1
        ;;
esac

# Clean temporary files and remove unused packages
cleanup

# Final check for any remaining issues (Debian-based only)
if [[ "$OS" == "ubuntu" || "$OS" == "debian" || "$OS" == "linuxmint" || "$OS" == "pop" || "$OS" == "elementary" || "$OS" == "zorin" || "$OS" == "kali" ]]; then
    print_step "Final system check"
    echo "Running final checks for any remaining package issues..."
    
    # Fix any remaining broken packages
    sudo apt --fix-broken install -y
    
    # Final dpkg configuration check
    sudo dpkg --configure -a
fi

# Restart system if necessary
print_step "Update process completed successfully"
echo "Would you like to restart the system now? (y/n)"
read -r REBOOT

if [[ $REBOOT == "y" || $REBOOT == "Y" ]]; then
    echo "System will restart in 10 seconds... Press Ctrl+C to cancel"
    sleep 10
    sudo reboot
else
    echo "Update process completed successfully. You may need to restart your system later to apply all updates."
fi

exit 0
