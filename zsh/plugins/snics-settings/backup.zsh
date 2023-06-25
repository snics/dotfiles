_backup_source_paths=(
  "~/.secrets"
  "~/.ssh/"
  "~/Projects/"
)
_backup_target_dir="$HOME/system-backup"
_backup_archive="$HOME/system-backup.tar.gz"


_rclone_backup_target="google-drive-backup"
_backup_target_path="${_rclone_backup_target}: /.backup"

_replace_start() {
    # $1 ist der originale String
    # $2 ist der zu ersetzende Startstring
    # $3 ist der Ersatzstring

    if [[ $1 == $2* ]]; then
        echo "${3}${1:${#2}}"
    else
        echo $1
    fi
}

_backup_mackup() {
  # create backup folder of mackup
  mkdir -p ~/mackup-backups

  # create backup with mackup (--force to overwrite existing backup and run without of ask)
  mackup backup --force
}

_backup_folder() {
  # Delete the target directory if it already exists
  rm -rf $_backup_target_dir
  # Create the target directory if it doesn't already exist
  mkdir -p $_backup_target_dir

  # Define an array of patterns to be excluded
  _exclude_patterns=(
    "*.tmp"
    "*.log"
    "cache/"
    ".idea/"
    "*~"
    ".fuse_hidden*"
    ".directory"
    ".Trash-*"
    ".nfs*"
    "Thumbs.db"
    "Thumbs.db:encryptable"
    "ehthumbs.db"
    "ehthumbs_vista.db"
    "*.stackdump"
    "[Dd]esktop.ini"
    "\$RECYCLE.BIN/"
    "*.cab"
    "*.msi"
    "*.msix"
    "*.msm"
    "*.msp"
    "*.lnk"
    ".DS_Store"
    ".AppleDouble"
    ".LSOverride"
    "Icon"
    "._*"
    ".DocumentRevisions-V100"
    ".fseventsd"
    ".Spotlight-V100"
    ".TemporaryItems"
    ".Trashes"
    ".VolumeIcon.icns"
    ".com.apple.timemachine.donotpresent"
    ".AppleDB"
    ".AppleDesktop"
    "Network Trash Folder"
    "Temporary Items"
    ".apdisk"
    "node_modules/"
  )

  _max=${#_backup_source_paths[@]}
  _index=1

  # Generate the exclude options
  _exclude_options=""
  for pattern in "${_exclude_patterns[@]}"; do
    _exclude_options+="--exclude=$pattern "
  done

  # Copy the files to the target directory with rsync, ignoring the patterns listed in the ignore file
  for _p in "${_backup_source_paths[@]}"; do
    _path=$(_replace_start "$_p" "~" "$HOME")
    _target_dir=$(_replace_start "$_p" "~" "_HOME")

    echo "Creating backup: $_index/$_max"
    mkdir -p "$_backup_target_dir/$_target_dir"
    rsync -a $_exclude_options $_path "$_backup_target_dir/$_target_dir"
    ((_index++))
  done

  # Archive and compress the target directory
  tar -zcvf "$_backup_archive" "$_backup_target_dir"

  # Delete the target directory after archiving and compressing
  # rm -rf $_backup_target_dir

  # Output a confirmation
  echo "Backup was successfully."
}

_upload_backup() {
  # Upload the archive to Google Drive
  rclone copy $_backup_archive $_backup_target_path --progress
  # Delete the archive after uploading
  rm $_backup_archive
}

_check_apps() {
    # Check if rclone is installed
    if ! command -v rclone &> /dev/null; then
        echo "Error: rclone is not installed. Please install rclone to proceed."
        return 1
    fi

    # Check if rsync is installed
    if ! command -v rsync &> /dev/null; then
        echo "Error: rsync is not installed. Please install rsync to proceed."
        return 1
    fi

    # Check if Google Drive configuration is present
    local config_dump=$(rclone config dump | jq --arg target "${_rclone_backup_target}" 'has($target)')
    if [ "$config_dump" = "false" ]; then
        echo "Error: Google Drive configuration not found. Please configure Google Drive with rclone to proceed."
        echo "The name of the configuration should be '${_rclone_backup_target}'."
        return 1
    fi
}


# Main update function
_backup() {
  # Ask user if they want to proceed
  echo -n "Do you want to perform the backup? (y/n):"
  read answer
  if [[ $answer =~ ^[Yy]$ ]]
  then
    # Check if rclone, rsync is installed and configured
    checking_apps=(_check_apps)

    # checking is checking_apps is not 1 (error)
    if [ "$checking_apps" != "1" ]; then
      echo "🔎 Creating backup..."
      echo "💼 Backup mackup..."
      _backup_mackup
      echo "📁 Backup folder..."
      _backup_folder
      echo "⬆️ Upload backup..."
      _upload_backup
      echo "✅ Backup was successful."

      echo "🧹 Cleanup temporary data..."
      echo "Cleanup data: 1/3"
      # Delete the target directory if it already exists
      # rm -rf $_backup_target_dir
      echo "Cleanup data: 2/3"
      # Delete the mackup backup folder
      # rm -rf ~/mackup-backups
      echo "Cleanup data: 3/3"
      # Delete the archive after uploading
      # rm $_backup_archive
      echo "✅ Cleanup temporary data was successful."
    fi
  else
    echo "🚫 Backup was canceled."
  fi
}

_restore() {
  # Check if rclone is installed and configured
  _check_rclone
}

alias backup=_backup
alias bup=_backup

alias restore=_restore
alias rs=_restore
