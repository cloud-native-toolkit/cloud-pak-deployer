from flask import Flask, send_from_directory,request
import json
import subprocess
import os
import yaml

app = Flask(__name__,static_url_path='', static_folder='ww')

source = os.path.dirname(__file__)
parent = os.path.join(source, '../')
script_path = os.path.join(parent, 'cp-deploy.sh')

@app.route('/',defaults={'path':''})
def index():
    return send_from_directory(app.static_folder,'index.html')


@app.route('/api/v1/deploy',methods=["POST"])
def deploy():
    body = json.loads(request.get_data())
    env ={}
    if body['cloud']=='IBMCloud':
      env = {'IBM_CLOUD_API_KEY': body['env']['ibmCloudAPIKey'],
                                'CP_ENTITLEMENT_KEY': body['env']['entilementKey']}
    process = subprocess.Popen([script_path, 'env', 'webui','-e env_id={}'.format(body['envId']),
                                '-e ibm_cloud_region={}'.format(body['region']), 
                                '--config-dir={}'.format(body['configDir']),'--status-dir={}'.format(body['statusDir']),
                                '--cpd-develop'], 
                           stdout=subprocess.PIPE,
                           universal_newlines=True,
                           env=env)
    return 'runing'

@app.route('/api/v1/loadConifg',methods=["POST"])
def loadConfig():
    body = json.loads(request.get_data())
    env_id=body['envId']
    confg_path=body['configDir']
    result={}
    result["cp4d"]=open(confg_path+'/cp4d.yaml', "r").read()
    result["envId"]=open(confg_path+'/config/{}.yaml'.format(env_id), "r").read()
    return json.dumps(result)
            
        
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port='32080', debug=False)    