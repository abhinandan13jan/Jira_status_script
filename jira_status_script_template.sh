set -e

authorization="Authorization: Bearer "$1

# $1 is argument sent to bash script which is the personal access token generated from JIRA

echo "<WELCOME_STATEMENT>"

# head refers to the heading for the SLACK post
head="\nCurrent Sprint Status"
head+="\n<PROJECT_NAME>" 

echo "<MAIN_HEADING>"

# filter reference 1 is the viewable browser link for a jira filter with a list of stories
# filter reference 2 is the rest api response of the same jira filter from where raw data like total, count can be fetched
# use filters as direct jira links are confusing

# This is block 1 of the slack message
hac_stories="\n\n*<SUB_CATEGORY1>*"
hac_stories+="\n1. <https://issues.redhat.com/issues/?filter=12396633 | Stories Done> ($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396633' -H "Accept: application/json" | jq '.total'))" 
# https://issues.redhat.com/issues/?filter=12396633 is viewable link to filter reference 1 || https://issues.redhat.com/rest/api/2/search?jql=filter=12396633 is link to api output for filter reference 2
hac_stories+="\n2. <https://issues.redhat.com/issues/?filter=12396635 | Stories In Review> ($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396635' -H "Accept: application/json" | jq '.total'))"
hac_stories+="\n3. <https://issues.redhat.com/issues/?filter=12396638 | Unassigned Stories>($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396638' -H "Accept: application/json" | jq '.total'))" 
hac_stories+="\n4. <https://issues.redhat.com/issues/?filter=12396637 | Ready for pointing stories> ($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396637' -H "Accept: application/json" | jq '.total'))" 

# This is block 2
echo "Fetching HAC bugs"

hac_bugs="\n\n*Bugs:*"
hac_bugs+="\n1. <https://issues.redhat.com/issues/?filter=12396774 | In Review> ($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396774' -H "Accept: application/json" | jq '.total'))" 
# https://issues.redhat.com/issues/?filter=12396774 is viewable link to filter reference 1 || https://issues.redhat.com/rest/api/2/search?jql=filter=12396774 is link to api output for filter reference 2
hac_bugs+="\n2. <https://issues.redhat.com/issues/?filter=12396775 | Stories QE Review> ($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396775' -H "Accept: application/json" | jq '.total'))" 
hac_bugs+="\n3. <https://issues.redhat.com/issues/?filter=12396777 | Open bugs count> ($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396777' -H "Accept: application/json" | jq '.total'))" 
hac_bugs+="\n4. <https://issues.redhat.com/issues/?filter=12396778 | Triaged Bugs> ($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396778' -H "Accept: application/json" | jq '.total'))" 

# this is block 3
echo "Fetching ODC stories"

odc_stories="\n*UI Stories*"
odc_stories+="\n1. <https://issues.redhat.com/issues/search?jql=project%20%3D%20ODC%20and%20component%20%3D%20UI%20AND%20type%20%3D%20Story%20AND%20Sprint%20in%20openSprints()%20and%20status%3DClosed | Stories Done>($(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=project%20%3D%20ODC%20and%20component%20%3D%20UI%20AND%20type%20%3D%20Story%20AND%20Sprint%20in%20openSprints()%20and%20status%3DClosed' -H "Accept: application/json" | jq '.total'))" 
odc_stories+="\n2. $(curl -s 'https://issues.redhat.com/rest/api/2/search?jql=project%20%3D%20ODC%20and%20component%20%3D%20UI%20AND%20type%20%3D%20Story%20AND%20Sprint%20in%20openSprints()%20and%20status%3D"Code%20Review"' -H "Accept: application/json" | jq '.total') <https://issues.redhat.com/issues/search?jql=project%20%3D%20ODC%20and%20component%20%3D%20UI%20AND%20type%20%3D%20Story%20AND%20Sprint%20in%20openSprints()%20and%20status%3D"Code%20Review"' | Stories In Review>" 
odc_stories+="\n3. <https://issues.redhat.com/issues/?filter=12390458 | Unassigned stories:> $(curl -s  -H "$authorization" 'https://issues.redhat.com/rest/api/2/search?jql=filter=12390458' -H "Accept: application/json" | jq '.total')"
odc_stories+="\n4. $(curl -s -H "$authorization" 'https://issues.redhat.com/rest/api/2/search?jql=filter=12390129' -H "Accept: application/json" | jq '.total') <https://issues.redhat.com/issues/?filter=12390129 | Ready for pointing story>" 

# this is block 4
echo "Fetching ODC bugs"

odc_bugs="\n*Bugs:*"
bugs=$(curl -H "$authorization" -s 'https://issues.redhat.com/rest/api/2/search?jql=(project%20%3D%20ODC%20AND%20component%20%3D%20UI%20AND%20type%20%3D%20Bug%20AND%20Sprint%20in%20openSprints()%20OR%20project%20%3D%20"OCP%20Bugs%20Mirroring"%20AND%20component%20%3D%20"Dev%20Console")%20and%20status%20in%20("In%20Review"%2C"Code%20Review")' -H "Accept: application/json" | jq '.total')
odc_bugs+="\n1.  <https://issues.redhat.com/issues/?filter=12396802 | Bugs In Review > ($bugs)" 
if [ $bugs -ge 20 ]; then
    odc_bugs+=" :fire::fire:"
fi
# using slack icons with if condition
odc_bugs+="\n   [$(curl -s -H "$authorization" 'https://issues.redhat.com/rest/api/2/search?jql=filter=12390129' -H "Accept: application/json" | jq '.total') for <https://issues.redhat.com/issues/search?jql=(project%20%3D%20ODC%20AND%20component%20%3D%20UI%20AND%20type%20%3D%20Bug%20AND%20Sprint%20in%20openSprints()%20OR%20project%20%3D%20%22OCP%20Bugs%20Mirroring%22%20AND%20component%20%3D%20%22Dev%20Console%22)%20and%20status%20in%20(%22In%20Review%22%2C%22Code%20Review%22)%20AND%20fixVersion%20in%20(%22OpenShift%204.11%22%2C%20%224.11.0%22) | 4.11> &"
odc_bugs+=" $(curl -s -H "$authorization" 'https://issues.redhat.com/rest/api/2/search?jql=(project%20%3D%20ODC%20AND%20component%20%3D%20UI%20AND%20type%20%3D%20Bug%20AND%20Sprint%20in%20openSprints()%20OR%20project%20%3D%20%22OCP%20Bugs%20Mirroring%22%20AND%20component%20%3D%20%22Dev%20Console%22)%20and%20status%20in%20(%22In%20Review%22%2C%22Code%20Review%22)%20AND%20fixVersion%20not%20in%20(%22OpenShift%204.11%22%2C%20%224.11.0%22)' -H "Accept: application/json" | jq '.total') for <https://issues.redhat.com/issues/search?jql=(project%20%3D%20ODC%20AND%20component%20%3D%20UI%20AND%20type%20%3D%20Bug%20AND%20Sprint%20in%20openSprints()%20OR%20project%20%3D%20%22OCP%20Bugs%20Mirroring%22%20AND%20component%20%3D%20%22Dev%20Console%22)%20and%20status%20in%20(%22In%20Review%22%2C%22Code%20Review%22)%20AND%20fixVersion%20not%20in%20(%22OpenShift%204.11%22%2C%20%224.11.0%22) | z-stream> ]"
echo $odc_bugs;
qe_bugs=$(curl -H  "$authorization" -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396805' -H "Accept: application/json" | jq '.total') 
odc_bugs+="\n2. <https://issues.redhat.com/issues/?filter=12396805 | Bugs In QE Review >($qe_bugs)" 
if [ $qe_bugs -ge 10 ]; then
    odc_bugs+=" :fire::fire:" 
fi
odc_bugs+="\n3. <https://issues.redhat.com/issues/?filter=12396806 | Unresolved blockers> ($(curl -H "$authorization" -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396806' -H "Accept: application/json" | jq '.total'))"
odc_bugs+="\n4. <https://issues.redhat.com/issues/?filter=12396807 | Triaged bugs> ($(curl -H "$authorization" -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396807' -H "Accept: application/json" | jq '.total'))"
openbugs=$(curl -H "$authorization" -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396824' -H "Accept: application/json" | jq '.total')
odc_bugs+="\n5. <https://issues.redhat.com/issues/?filter=12396824 | Open Bug count:> ($openbugs)"
if [ $openbugs -ge 40 ]; then
    odc_bugs+=" :fire::fire:"
fi
odc_bugs+="\n6. <https://issues.redhat.com/issues/?filter=12396825 | Total open bugs (incl. untriaged, blocked):> ( $(curl -H "$authorization" -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396825' -H "Accept: application/json" | jq '.total'))" 
odc_bugs+="\n7. <https://issues.redhat.com/issues/?filter=12396826 | Open Bugzilla :> ($(curl -H "$authorization" -s 'https://issues.redhat.com/rest/api/2/search?jql=filter=12396826' -H "Accept: application/json" | jq '.total'))" 

echo "Fetching Github data"

# block 5
github_data="\n<https://github.com/search?q=repo%3Aopenshift%2Fhac-dev+repo%3Aopenshift%2Fconsole+repo%3Aopenshift%2Fenhancements+repo%3Aopenshift%2Fconsole-operator+repo%3Aopenshift%2Fapi+-label%3Ado-not-merge%2Fwork-in-progress+-label%3Algtm+author%3Arohitkrai03+author%3Adebsmita1+author%3Ajeff-phillips-18+author%3AinvincibleJai+author%3Anemesis09+author%3Asahil143+author%3Avikram-raj+author%3Achristianvogt+author%3Ajerolimov+author%3AdivyanshiGupta+author%3Arottencandy+author%3Akarthikjeeyar+author%3Aabhinandan13jan+state%3Aopen+created%3A%3C2022-06-19+author%3ALucifergene+author%3Agruselhaus+author%3Alokanandaprabhu&type=Issues&ref=advsearch&l=&l= | PRs Opened for more than 7 days>:  $(curl -s 'https://api.github.com/search/issues?q=repo%3Aopenshift%2Fhac-dev+repo%3Aopenshift%2Fconsole+repo%3Aopenshift%2Fenhancements+repo%3Aopenshift%2Fconsole-operator+repo%3Aopenshift%2Fapi+-label%3Ado-not-merge%2Fwork-in-progress+-label%3Algtm+author%3Arohitkrai03+author%3Adebsmita1+author%3Ajeff-phillips-18+author%3AinvincibleJai+author%3Anemesis09+author%3Asahil143+author%3Avikram-raj+author%3Achristianvogt+author%3Ajerolimov+author%3AdivyanshiGupta+author%3Arottencandy+author%3Akarthikjeeyar+author%3Aabhinandan13jan+state%3Aopen+created%3A%3C2022-06-19+author%3ALucifergene+author%3Agruselhaus+author%3Alokanandaprabhu&type=repositories' -H "Accept: application/json" | jq '.total_count')"
github_data+="\n<https://github.com/search?q=repo%3Aopenshift%2Fconsole+repo%3Aopenshift%2Fenhancements+repo%3Aopenshift%2Fconsole-operator+repo%3Aopenshift%2Fapi+repo%3Aopenshift%2Fhac-dev+-label%3Ado-not-merge%2Fwork-in-progress+-label%3Algtm+author%3Arohitkrai03+author%3Adebsmita1+author%3Ajeff-phillips-18+author%3AinvincibleJai+author%3Anemesis09+author%3Asahil143+author%3Avikram-raj+author%3Achristianvogt+author%3Ajerolimov+author%3AdivyanshiGupta+author%3Arottencandy+author%3Akarthikjeeyar+author%3Aabhinandan13jan+author%3Ayozaam+state%3Aopen+author%3ALucifergene+author%3Agruselhaus+author%3Alokanandaprabhu&type=Issues&ref=advsearch&l=&l= | PRs with No LGTM>: $(curl -s 'https://api.github.com/search/issues?q=repo%3Aopenshift%2Fconsole+repo%3Aopenshift%2Fenhancements+repo%3Aopenshift%2Fconsole-operator+repo%3Aopenshift%2Fapi+repo%3Aopenshift%2Fhac-dev+-label%3Ado-not-merge%2Fwork-in-progress+-label%3Algtm+author%3Arohitkrai03+author%3Adebsmita1+author%3Ajeff-phillips-18+author%3AinvincibleJai+author%3Anemesis09+author%3Asahil143+author%3Avikram-raj+author%3Achristianvogt+author%3Ajerolimov+author%3AdivyanshiGupta+author%3Arottencandy+author%3Akarthikjeeyar+author%3Aabhinandan13jan+author%3Ayozaam+state%3Aopen+author%3ALucifergene+author%3Agruselhaus+author%3Alokanandaprabhu&type=Issues&ref=advsearch&l=&l=' -H "Accept: application/json" | jq '.total_count')" 
github_data+="\n<https://github.com/search?q=repo%3Aopenshift%2Fhac-dev+repo%3Aopenshift%2Fconsole+repo%3Aopenshift%2Fenhancements+repo%3Aopenshift%2Fconsole-operator+repo%3Aopenshift%2Fapi+-label%3Aapproved+label%3Algtm+author%3Arohitkrai03+author%3Adebsmita1+author%3Ajeff-phillips-18+author%3AinvincibleJai+author%3Anemesis09+author%3Asahil143+author%3Avikram-raj+author%3Achristianvogt+author%3Ajerolimov+author%3Ayozaam+author%3AdivyanshiGupta+author%3Arottencandy+author%3Akarthikjeeyar+author%3Aabhinandan13jan+state%3Aopen+author%3ALucifergene+author%3Agruselhaus+author%3Alokanandaprabhu&type=Issues&ref=advsearch&l=&l= | PRs without Approval>: $(curl -s 'https://api.github.com/search/issues?q=repo%3Aopenshift%2Fhac-dev+repo%3Aopenshift%2Fconsole+repo%3Aopenshift%2Fenhancements+repo%3Aopenshift%2Fconsole-operator+repo%3Aopenshift%2Fapi+-label%3Aapproved+label%3Algtm+author%3Arohitkrai03+author%3Adebsmita1+author%3Ajeff-phillips-18+author%3AinvincibleJai+author%3Anemesis09+author%3Asahil143+author%3Avikram-raj+author%3Achristianvogt+author%3Ajerolimov+author%3Ayozaam+author%3AdivyanshiGupta+author%3Arottencandy+author%3Akarthikjeeyar+author%3Aabhinandan13jan+state%3Aopen+author%3ALucifergene+author%3Agruselhaus+author%3Alokanandaprabhu&type=Issues&ref=advsearch&l=&l=' | jq '.total_count')" 

echo "Posting on slack"

# final curl call with api
# curl -X POST -H "Content-type:application/json" --data "<FORMATTED SLACK MESSAGE>" <slack-incoming-webhook-url>
curl -X POST -H "Content-type:application/json" --data "{\"type\":\"home\", \"blocks\":[{\"type\":\"header\",\"text\":{\"type\":\"plain_text\",\"text\":\"$head\"}},{\"type\":\"section\",\"fields\":[{\"type\":\"mrkdwn\",\"text\":\"$hac_stories\"},{\"type\":\"mrkdwn\",\"text\":\"$hac_bugs\"}]},{\"type\":\"divider\"},{\"type\":\"header\",\"text\":{\"type\":\"plain_text\",\"text\":\"ODC\"}},{\"type\":\"section\",\"fields\":[{\"type\":\"mrkdwn\",\"text\":\"$odc_stories\"},{\"type\":\"mrkdwn\",\"text\":\"$odc_bugs\"}]},{\"type\":\"divider\"},{\"type\":\"header\",\"text\":{\"type\":\"plain_text\",\"text\":\"Github Status\"}},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"$github_data\"}}]}" <webhook-url>


echo "\nDone"