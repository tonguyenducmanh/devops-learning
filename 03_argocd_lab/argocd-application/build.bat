REM del *.tgz
REM helm package .
helm cm-push ./ sre -u robot@viewer -p 12345678@Abc
@REM start http://192.168.41.109/harbor/projects/2/helm-charts/misa-monitoring-stack/versions
start http://jenkins.misa.local/job/SRE/job/push_sre_charts_2_prod/build?delay=0sec
