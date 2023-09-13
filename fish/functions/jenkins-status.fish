function jenkins-status
  curl 'https://jenkins.common.cloud.aurora.tech/job/av-localization-map-build-regression/198/api/json' \
    -c ~/cookies.txt -b ~/cookies.txt \
    -H 'Connection: keep-alive' \
    -H 'Cache-Control: max-age=0' \
    -H 'sec-ch-ua: " Not;A Brand";v="99", "Google Chrome";v="91", "Chromium";v="91"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.106 Safari/537.36' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
    -H 'Sec-Fetch-Site: none' \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-User: ?1' \
    -H 'Sec-Fetch-Dest: document' \
    -H 'Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7' \
    -H 'Cookie: GCP_IAP_UID=100654227307377664070; jenkins-timestamper-offset=25200000; jenkins-timestamper=system; jenkins-timestamper-local=true; ambassador_session.oidc-core-prod.ambassador-public=07be2af43789a362f336822cec6aa8a445a6d41633cc397397eb1516355ad45d; ambassador_xsrf.oidc-core-prod.ambassador-public=74f5fe2701309d767ff10c8dc1aa18fdff98407e08d1c86a8a4e55915927d8c1; JSESSIONID.4c49c0a5=node0pni696kbwl9uwr6zquuw5vd9930381.node0; ambassador_session.oidc-common.ambassador-public=c5c7d046f58c32e59f2803bd0efc8ba995a82ed4c64f0489ae221f3340f3ef59; ambassador_xsrf.oidc-common.ambassador-public=d2816e4e9a00c6ee29a5852e5e122a4b831d42cf53b63291225e1faf3961fe4f' \
    --compressed \
    | string match -r '(?<="result":)"?[A-Za-z]+"?'
end
