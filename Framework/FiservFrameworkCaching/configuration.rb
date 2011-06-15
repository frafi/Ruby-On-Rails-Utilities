require "FiservFrameworkCommon"
require "FiservFrameworkData"
require "FiservFrameworkExceptions"

module FiservFrameworkCaching
	class Configuration # <summary>
		def initialize()
			@enableTimer = nil
			@enableSsl = nil
			@serverCacheExpirationHours = nil
			@clientCacheExpirationHours = nil
			self.Initialize()
		end

		def Configuration.Initialize()
			begin
				@domainName = Configuration.GetGlobalSetting("DomainName")
				@productName = Configuration.GetGlobalSetting("ProductName")
				@physicalRoot = Configuration.GetGlobalSetting("PhysicalRoot")
				if not Directory.Exists(@physicalRoot) then
					raise CommonException.new(System::String.Format("Parameter 'PhysicalRoot' points to a path '{0}' that does not exist.", @physicalRoot))
				end
				# Log to the event log.
				Tracing.WriteEntry(String.Format("Application '{0}' located in '{1}' initialized for domain '{2}'.", AppDomain.CurrentDomain.FriendlyName, AppDomain.CurrentDomain.BaseDirectory, @domainName))
			rescue Exception => ex
				# NOTE:  This is the ONLY code that is directly calling the EventLog class, because
				# it must NOT call the Tracing class.  Otherwise, it will go into an infinate loop!
				EventLog.WriteEntry(AppDomain.CurrentDomain.FriendlyName, String.Format("Failed to initialize application '{0}' located in '{1}': {2}\n\n{3}", AppDomain.CurrentDomain.FriendlyName, AppDomain.CurrentDomain.BaseDirectory, ex.Message, Utilities.GetInnerException(ex)), EventLogEntryType.Error, 1049)
				raise CommonException.new("Failed to initialized application", ex)
			ensure
			end
		end

		def MessageActivity
			return DatabaseActivity.new(@domainName, "MESSAGE")
		end

		def DomainName
			return @domainName
		end

		def EndpointName
			return self.GetGlobalSetting("ServiceEndpoint")
		end

		def PhysicalRoot
			return @physicalRoot + "\\"
		end

		def ProductName
			return @productName
		end

		def ConfigPath
			return @physicalRoot + "\\config\\"
		end

		def DomainConfigFile
			return @physicalRoot + "\\config\\Domain.config"
		end

		def LogPath
			return @physicalRoot + "\\log\\"
		end

		def WorkingPath
			return @physicalRoot + "\\working\\"
		end

		def JobPath
			return @physicalRoot + "\\job\\"
		end

		def SchemaPath
			return @physicalRoot + "\\schema\\"
		end

		def TracePath
			return @physicalRoot + "\\trace\\"
		end

		def AssemblyPath
			return @physicalRoot + "\\bin\\"
		end

		def FormatPath
			return @physicalRoot + "\\fmt\\"
		end

		def LogoPath
			return @physicalRoot + "\\logos\\"
		end

		def PerfmonId
			if System::String.IsNullOrEmpty(@perfmonId) then
				@perfmonId = self.GetGlobalSetting("PerfmonId")
			end
			return @perfmonId
		end

		def SecurityTokenFile
			if System::String.IsNullOrEmpty(@securityTokenFile) then
				@securityTokenFile = self.GetGlobalSetting("SecurityTokenFile")
			end
			return @securityTokenFile
		end

		def EnableTimer
			if @enableTimer == nil then
				enableTimerValue = self.GetGlobalSetting("EnableTimer").ToUpper()
				if enableTimerValue == "TRUE" or enableTimerValue == "ON" then
					@enableTimer = true
				else
					@enableTimer = false
				end
			end
			return @enableTimer
		end

		def EnableSsl
			if @enableSsl == nil then
				enableSslValue = self.GetGlobalSetting("EnableSSL").ToUpper()
				if enableSslValue == "TRUE" or enableSslValue == "ON" then
					@enableSsl = true
				else
					@enableSsl = false
				end
			end
			return @enableSsl
		end

		def ServerCacheExpirationHours
			if @serverCacheExpirationHours == nil then
				@serverCacheExpirationHours = Convert.ToInt32(self.GetGlobalSetting("ServerCacheExpirationHours"))
			end
			return @serverCacheExpirationHours
		end

		def ClientCacheExpirationHours
			if @clientCacheExpirationHours == nil then
				@clientCacheExpirationHours = Convert.ToInt32(self.GetGlobalSetting("ClientCacheExpirationHours"))
			end
			return @clientCacheExpirationHours
		end

		def Configuration.IsTraced()
			return WebCache.IsTraced()
		end

		def Configuration.IsTraced(creditUserActivity)
			return WebCache.IsTraced(creditUserActivity)
		end

		def Configuration.GetCrediantials(companyNbr)
			# Build the key.
			lookupKey = System::String.Format("Company{0}Credentials", companyNbr)
			# Look in the cache.
			credentials = WebCache.GetParameter(lookupKey)
			if credentials == nil then
				# Load the config file.
				xmlDoc = XmlDocument.new()
				xmlDoc.Load(self.DomainConfigFile)
				xmlNode = xmlDoc.SelectSingleNode("//Parameters/" + lookupKey)
				if xmlNode == nil then
					error = System::String.Format("Node '{0}' not found in Domain.config file.", lookupKey)
					Tracing.WriteEntry(1050, error)
					raise CommonException.new(error)
				end
				if xmlNode["UserId"] == nil or xmlNode["Password"] == nil or xmlNode["Domain"] == nil then
					error = System::String.Format("UserId, Password, and/or Domain not defined for '{0}' in Domain.config file.", lookupKey)
					Tracing.WriteEntry(1051, error)
					raise CommonException.new(error)
				end
				# Instantiate an object.
				#ToDo!  Do we need to use a different function to accomodate empty string InnerText value??
				credentials = CompanyCredentials.new()
				credentials.UserId = xmlNode["UserId"].InnerText
				credentials.Password = xmlNode["Password"].InnerText
				credentials.Domain = xmlNode["Domain"].InnerText
				credentials.FromCache = false
				# Add it to the cache.
				WebCache.AddParameter(lookupKey, credentials)
			else
				# If we find credentials in the cache, we flag them.
				credentials.FromCache = true
			end
			# A null credentials variable is not expected up to this point, because we either found something
			# in the cache or we raised an exception because company-level credentials are not defined.  However,
			# we need the ability to disable impersonation.  Impersonation is disabled if the UserId is an empty
			# string.  If disabled, we'll return a null CompanyCredentials class.
			if credentials.UserId == System::String.Empty then
				credentials = nil
			end
			# Return credentials object.
			return credentials
		end

		# <summary>
		# Get domain parameter value as string from the cache.
		# </summary>
		# <param name="parameterKey"></param>
		# <returns></returns>
		def Configuration.GetParameter(parameterKey)
			# Get config value from the Parameter cache.
			parameterValue = WebCache.GetParameter(parameterKey)
			# if Parameter name is missing from config file throw an Exception.
			if parameterValue == nil then
				raise ArgumentException.new(System::String.Format("Parameter is missing in domain config '{0}'", parameterKey))
			end
			return parameterValue
		end

		# <summary>
		# Get domain parameter value as integer from the cache.
		# </summary>
		# <returns></returns>
		def Configuration.GetParameterAsInteger(parameterKey)
			begin
				parameterValue = Configuration.GetParameter(parameterKey)
				return Convert.ToInt32(parameterValue)
			rescue Exception => e
				raise CommonException.new(System::String.Format("Failed to get parameter value '{0}' as an integer from the cache -> {1}", parameterKey, e.Message))
			ensure
			end
		end

		# <summary>
		# Add a domain parameter to the system cache.
		# Currently, only used by unit test framework.
		# </summary>
		# <param name="key"></param>
		# <param name="itemValue"></param>
		def Configuration.AddParameterToCache(key, itemValue)
			begin
				WebCache.AddParameter(key, itemValue)
			rescue Exception => e
				raise CommonException.new(String.Format("Failed to add parameter '{0}' to the application cache: {1}", key, e.Message))
			ensure
			end
		end

		# <summary>
		# Refresh the application cache by invalidating the current cache
		# and re-populating it with domain parameters.
		# </summary>
		def Configuration.RefreshCache()
			# Refresh global variables.
			Configuration.Initialize()
			# Refresh parameter cache
			WebCache.Refresh()
		end

		# <summary>
		# Read entire contents of the application cache.
		# </summary>
		# <returns></returns>
		def Configuration.ReadCache()
			return WebCache.ReadContents()
		end

		# <summary>
		# Get domain module value as string from the cache.
		# ToDo! Rewrite this to provide a new way to cache and lookup company/center name-value pairs.
		# </summary>
		# <param name="creditCenterNbr"></param>
		# <param name="moduleId"></param>
		# <returns></returns>
		def Configuration.GetModule(creditCenterNbr, moduleId)
			raise InvalidOperationException.new("Obsolete and needs to be refactored!")
		end

		#try
		#{
		#    // Get config value from the Parameter cache.
		#    string moduleValue = WebCache.GetModule<string>(creditCenterNbr, moduleId);
		#    if (string.IsNullOrEmpty(moduleValue))
		#    {
		#        throw new ArgumentException("Empty value in cache");
		#    }
		#    return moduleValue;
		#}
		#catch (Exception e)
		#{
		#    throw new CommonException(string.Format("Failed to get module value '{0}' from the cache for domain '{1}' -> {2}", moduleId, domainName, e.Message));
		#}
		# <summary>
		# Read configuration parameter as string from the system config file.
		# </summary>
		# <param name="name"></param>
		def Configuration.GetGlobalSetting(name)
			appSettings = ConfigurationManager.AppSettings
			if appSettings == nil then
				raise CommonException.new("Failed to access ConfigurationManager.AppSettings")
			end
			#to Check if Key is not missing in config.
			if appSettings.GetValues(name) == nil then
				raise CommonException.new(System::String.Format("Application setting '{0}' is missing in the system/web config file.", name))
			end
			configValue = appSettings[name]
			if configValue == nil then
				raise CommonException.new(System::String.Format("Invalid/empty application setting '{0}' in the system/web config file.", name))
			end
			return configValue
		end
	end
	# <summary>
	# Database credentials for a given company and domain.
	# </summary>
	class CompanyCredentials
		# <summary>
		# Directory Domain
		# </summary>
		def Domain
		end

		def Domain=(value)
		end

		# <summary>
		# User ID
		# </summary>
		def UserId
		end

		def UserId=(value)
		end

		# <summary>
		# Password
		# </summary>
		def Password
		end

		def Password=(value)
		end

		# <summary>
		# Indicates if credentials were validated.
		# </summary>
		def FromCache
		end

		def FromCache=(value)
		end
	end
	# <summary>
	# Enumeration for tracing level
	# </summary>
	class TracingLevel
		def initialize()
		end

	end
end