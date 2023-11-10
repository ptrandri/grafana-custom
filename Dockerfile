FROM grafana/grafana:9.3.6

# Set Grafana options
ENV GF_ENABLE_GZIP=true
ENV GF_USERS_DEFAULT_THEME=light

# Sanitize
ENV GF_PANELS_DISABLE_SANITIZE_HTML=true

# Explore
ENV GF_EXPLORE_ENABLED=false

# Alerting
ENV GF_ALERTING_ENABLED=false
ENV GF_UNIFIED_ALERTING_ENABLED=false

# Copy artifacts
COPY entrypoint.sh /
###### Customization ########################################
USER root

# Replace Image
COPY img/fav32.png /usr/share/grafana/public/img
COPY img/logo.svg /usr/share/grafana/public/img/grafana_icon.svg
COPY img/background.svg /usr/share/grafana/public/img/g8_login_dark.svg
COPY img/background.svg /usr/share/grafana/public/img/g8_login_light.svg

# Mengedit File Index Loading
RUN sed -i 's/Loading Grafana/Loading Dashboard/g' /usr/share/grafana/public/views/index.html

# Mengedit Title
RUN sed -i 's|<title>\[\[.AppTitle\]\]</title>|<title>Rootguards Monitoring</title>|g' /usr/share/grafana/public/views/index.html

# Mengedit file konfigurasi Grafana
RUN sed -i 's|\[navigation.app_sections\]|\[navigation.app_sections\]\rootguards-app=root|g' /usr/share/grafana/conf/defaults.ini

# Mengedit file HTML untuk memodifikasi menu bantuan
RUN sed -i "s|\[\[.NavTree\]\],|nav,|g; \
    s|window.grafanaBootData = {| \
    let nav = [[.NavTree]]; \
    nav[nav.length -1]['subTitle'] = 'Application'; \
    window.grafanaBootData = {|g" \
    /usr/share/grafana/public/views/index.html

### Update Title
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|"AppTitle","Grafana")|"AppTitle","Rootguards Monitoring")|g' {} \;
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|"LoginTitle","Welcome to Grafana")|"LoginTitle","Welcome to Rootguards Dashboard")|g' {} \;
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|{target:"_blank",id:"documentation",text:(0,r.t)("nav.help/documentation","Documentation"),icon:"document-info",url:"https://grafana.com/docs/grafana/latest/?utm_source=grafana_footer"},{target:"_blank",id:"support",text:(0,r.t)("nav.help/support","Support"),icon:"question-circle",url:"https://grafana.com/products/enterprise/?utm_source=grafana_footer"},{target:"_blank",id:"community",text:(0,r.t)("nav.help/community","Community"),icon:"comments-alt",url:"https://community.grafana.com/?utm_source=grafana_footer"}||g' {} \;
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|{target:"_blank",id:"version",text:`${e.edition}${s}`,url:t.licenseUrl}||g' {} \;
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|{target:"_blank",id:"version",text:`v${e.version} (${e.commit})`,url:i?"https://github.com/grafana/grafana/blob/main/CHANGELOG.md":void 0}||g' {} \;
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|{target:"_blank",id:"updateVersion",text:"New version available!",icon:"download-alt",url:"https://grafana.com/grafana/download?utm_source=grafana_footer"}||g' {} \;
#############################################################

USER grafana
# Entrypoint
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
