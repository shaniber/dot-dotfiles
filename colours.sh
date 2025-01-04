## Pretty colours.
reverse=$(tput rev)
bold=$(tput bold)
noColour=$(tput sgr 0)

black=$(tput setaf 232)
white=$(tput setaf 007)
brown=$(tput setaf 003)
red=$(tput setaf 001)
orange=$(tput setaf 202)
yellow=$(tput setaf 003)
green=$(tput setaf 002)
cyan=$(tput setaf 006)
blue=$(tput setaf 004)
magenta=$(tput setaf 005)
lblue=$(tput setaf 033)

lbluebg=$(tput setab 033)

lred='\e[91m'
lgreen='\e[92m'
yellow='\e[93m'
lpurple='\e[95m'
lcyan='\e[96m'
lgray='\e[37m'
dgray='\e[90m'

dashes="$(s=$(printf "%*s" 3); echo "${s// /―}")"

readonly reverse bold noColour 
readonly black white brown red orange yellow green cyan blue magenta 
readonly lblue lred lgreen yellow lpurple lcyan lgray dgray
readonly lbluebg
readonly dashes