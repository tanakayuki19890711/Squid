import os
os.environ['HTTP_PROXY'] == 'http://cached-proxy:3128'
os.environ['http_proxy'] == 'http://cached-proxy:3128'
os.environ['HTTPS_PROXY'] == 'http://cached-proxy:3128'
os.environ['https_proxy'] == 'http://cached-proxy:3128'

print(os.environ['https_proxy'])
