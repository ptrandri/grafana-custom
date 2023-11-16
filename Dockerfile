# Menggunakan gambar Grafana versi 10.1.5
FROM grafana/grafana:10.1.5

# Beralih ke pengguna root untuk mengedit file
USER root
COPY entrypoint.sh /

# Custom ENV
ENV GF_ENABLE_GZIP=true
ENV GF_USERS_DEFAULT_THEME=light

# Menyalin file gambar dan logo ke direktori yang sesuai di dalam kontainer
COPY img/fav32.png /usr/share/grafana/public/img
COPY img/fav32.png /usr/share/grafana/public/img/apple-touch-icon.png
COPY img/logo.svg /usr/share/grafana/public/img/grafana_icon.svg
COPY img/background.svg /usr/share/grafana/public/img/g8_login_dark.svg
COPY img/background.svg /usr/share/grafana/public/img/g8_login_light.svg

# Mengedit File Index Loading
RUN sed -i 's/Loading Grafana/Loading Dashboard/g' /usr/share/grafana/public/views/index.html

# Mengedit judul pada file HTML
RUN sed -i 's|<title>\[\[.AppTitle\]\]</title>|<title>Rootguards Monitoring</title>|g' /usr/share/grafana/public/views/index.html

# Mengedit file konfigurasi Grafana
RUN sed -i 's|\[navigation.app_sections\]|\[navigation.app_sections\]\nvolkovlabs-app=root|g' /usr/share/grafana/conf/defaults.ini

# Mengedit file HTML untuk memodifikasi menu bantuan
RUN sed -i "s|\[\[.NavTree\]\],|nav,|g; \
    s|window.grafanaBootData = {| \
    let nav = [[.NavTree]]; \
    const alerting = nav.find((element) => element.id === 'alerting'); \
    if (alerting) { alerting['url'] = '/alerting/list'; } \
    const dashboards = nav.find((element) => element.id === 'dashboards/browse'); \
    if (dashboards) { dashboards['children'] = [];} \
    const connections = nav.find((element) => element.id === 'connections'); \
    if (connections) { connections['url'] = '/datasources'; connections['children'].shift(); } \
    const help = nav.find((element) => element.id === 'help'); \
    if (help) { help['subTitle'] = 'Grafana OSS'; help['children'] = [];} \
    window.grafanaBootData = {|g" \
    /usr/share/grafana/public/views/index.html

## Update Title
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|AppTitle="Grafana"|AppTitle="Rootguards Monitoring"|g' {} \;

## Update Login Title
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|LoginTitle="Welcome to Grafana"|LoginTitle="Welcome to Rootguards Dashboard"|g' {} \;

## Remove Documentation, Support, Community in the Footer
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|\[{target:"_blank",id:"documentation".*grafana_footer"}\]|\[\]|g' {} \;

## Remove Edition in the Footer
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|({target:"_blank",id:"license",.*licenseUrl})|()|g' {} \;

## Remove Version in the Footer
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|({target:"_blank",id:"version",.*CHANGELOG.md":void 0})|()|g' {} \;

## Remove New Version is available in the Footer
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|({target:"_blank",id:"updateVersion",.*grafana_footer"})|()|g' {} \;

## Remove News icon
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|..createElement(....,{className:.,onClick:.,iconOnly:!0,icon:"rss","aria-label":"News"})|null|g' {} \;

## Remove Open Source icon
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|.push({target:"_blank",id:"version",text:`${..edition}${.}`,url:..licenseUrl,icon:"external-link-alt"})||g' {} \;

# Mengganti pengguna kembali ke "grafana" sebelum menjalankan aplikasi
USER grafana

# Entry point untuk aplikasi Grafana

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
