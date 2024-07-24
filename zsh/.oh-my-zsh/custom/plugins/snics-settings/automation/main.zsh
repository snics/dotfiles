
_sort_files() {
    local ext_array=("$@")
    local category=$1
    shift
    for ext in "${ext_array[@]}"; do
    for file in "$folder"/*."$ext"; do
    mv "$file" "$folder/$category"
    done
    done
}

_spinner() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c] " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
    done
    printf " \b\b\b\b"
}

sort () {
    folder="."

    if [ ! -z "$1" ]; then
    folder=$1
    fi

    image_ext=(
    "jpg"
    "jpeg"
    "png"
    "gif"
    )

    document_ext=(
    "doc"
    "docx"
    "pdf"
    "txt"
    "rtf"
    )

    code_ext=(
    "c"
    "cpp"
    "py"
    "java"
    "js"
    "html"
    "css"
    "rb"
    )

    compressed_ext=(
    "zip"
    "rar"
    "tar"
    "gz"
    )

    audio_ext=(
    "mp3"
    "ogg"
    "flac"
    "aac"
    "wma"
    )

    mkdir -p "$folder/1.Bilder" "$folder/2.Dokumente" "$folder/3.Audio" "$folder/4.Code" "$folder/5.Komprimierte Dateien"

    sort_files "${image_ext[@]}" "1.Bilder" & _spinner $!
    sort_files "${document_ext[@]}" "2.Dokumente" & _spinner $!
    sort_files "${audio_ext[@]}" "3.Audio" & _spinner $!
    sort_files "${code_ext[@]}" "4.Code" & _spinner $!
    sort_files "${compressed_ext[@]}" "5.Komprimierte Dateien" & _spinner $!

}

