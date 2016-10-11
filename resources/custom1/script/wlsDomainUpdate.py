####################################
# Base WLS Domain Creation script  #
####################################

from jarray import array
from java.io import File
from sets import Set
from java.io import FileInputStream
from java.util import Properties
from java.lang import Exception
import re
import ConfigParser




def getConfigSectionMap(config, section):
    dict1 = {}
    options = config.options(section)

    listedOptions = ''
    for option in options:
        listedOptions += option + ' '
        try:
            dict1[option] = config.get(section, option)
            if dict1[option] == -1:
                DebugPrint("skip: %s" % option)
        except:
            print("exception on %s!" % option)
            dict1[option] = None
    print 'Section['+section+'] > props : ' + listedOptions
    return dict1

def loadGlobalProp(domainConfig):
   global WL_HOME, SERVER_NAME, DOMAIN, DOMAIN_PATH, DOMAIN_NAME, WLS_USER, WLS_PASSWD

   WL_HOME     = str(domainConfig.get('wlsHome'))
   DOMAIN_PATH = str(domainConfig.get('domainPath'))

   WLS_USER    = str(domainEnvConfig.get('wlsUser'))
   WLS_PASSWD  = str(domainEnvConfig.get('wlsPasswd'))

   SERVER_NAME = 'myserver'
   DOMAIN_NAME = 'cfDomain'

   if 'serverName' in domainConfig:
    SERVER_NAME = str(domainConfig.get('serverName'))

   if 'domainName' in domainConfig:
      DOMAIN_NAME = str(domainConfig.get('domainName'))

   DOMAIN      = DOMAIN_PATH + '/' + DOMAIN_NAME


def usage():
  print "Need to pass properties file as argument to script!!"
  exit(-1)



#==========================================
#  Edit the following block to add the updates
#==========================================
def updateDomainConfig(domainEnvConfig):
 try:
  print "Add any update steps...\n"

 except:
  dumpStack()


try:
  if (len(sys.argv) < 1):
    Usage()

  propFile = sys.argv[1]
  domainConfigProps = ConfigParser.ConfigParser()
  domainConfigProps.optionxform = str
  domainConfigProps.read(propFile)

  domainEnvConfig = getConfigSectionMap(domainConfigProps, 'Domain')
  loadGlobalProp(domainEnvConfig)

  print 'Connecting to server using: ' + WLS_USER + ':' + WLS_PASSWD + ' running at: t3://localhost:7001'
  connect(WLS_USER,  WLS_PASSWD, 't3://localhost:7001')
  cd('Servers/' + SERVER_NAME)

  edit()
  startEdit()

  updateDomainConfig(domainEnvConfig)

  save()
  activate()
  shutdown()


finally:
  dumpStack()
  print 'Done'
  exit
