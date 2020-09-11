touch "README${count_val}.md"
printf "${service_name}\n==========" >> "README${count_val}.md"
curl -u ${username}:${password} -X POST https://api.bitbucket.org/2.0/repositories/${username}/${slug}/src -F README.md=@README${count_val}.md
rm "README${count_val}.md"