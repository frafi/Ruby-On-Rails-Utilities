require "FiservFrameworkCaching"
require "FiservFrameworkCommon"
require "FiservFrameworkExceptions"
require "FiservFrameworkSecurity"

module FiservFrameworkData
	# <summary>
	# Qualifies type of activity.  The default behavior is that the activity is
	# related to OLTP data flow.  However, archive and ODS activity can be explicity
	# specified in the Activity context.
	# </summary>
	class ActivityType
		def initialize()
		end

		# <summary>
		# Default activity/data source type.
		# </summary>
		# <summary>
		# Archive data source.
		# </summary>
		# <summary>
		# Document data source.
		# </summary>
	end
	class Activity
		def initialize()
			# <summary>
			# Abstract Base Activity class, derived for specific context flows.
			# Activity context flows with all data.  There are six types:
			# 1. CreditUserActivity -- Credit database user activity from web tier.
			# 2. DatabaseActivity -- Specified database activity (TRM, CENTRAL, etc).
			# 3. VendorActivity -- Vendor database activity initiated by vendor interface.
			# </summary>
			@ENGLISH_CULTURE = "en-US"
			@SPANISH_CULTURE = "es-ES"
			@FRENCH_CULTURE = "fr-FR"
			@activityId = Guid.NewGuid().ToString()
			@activityType = ActivityType.Oltp
			@culture = @ENGLISH_CULTURE
		end

		def ActivityId # <summary>
			# Activity ID is a GUID that can be set by consumer that
			# originates the data flow.  If not, it is set by the message
			# engine if interception is performed.
			# </summary>
			return @activityId
		end

		def ActivityId=(value)
			begin
				# Use Guid() to check for valid UUID.
				Guid.new(value)
				@activityId = value
			rescue Exception =>
				raise ArgumentException.new("Error creating GUID from provided value.")
			ensure
			end
		end

		def DomainName
		end

		def DomainName=(value)
		end

		def SystemNbr
		end

		def SystemNbr=(value)
		end

		def UserId
		end

		def UserId=(value)
		end

		def ActivityType
			# <summary>
			# Domain Name
			# </summary>
			# <summary>
			# Application System Number
			# </summary>
			# <summary>
			# Application User ID
			# </summary>
			# <summary>
			# Activity Type
			# </summary>
			return @activityType
		end

		def ActivityType=(value)
			@activityType = value
		end

		def Culture
			# <summary>
			# Culture/Language of the User
			# </summary>
			return @culture
		end

		def Culture=(value)
			if value == "" or value.Equals(@ENGLISH_CULTURE, StringComparison.CurrentCultureIgnoreCase) then
				@culture = @ENGLISH_CULTURE
			elsif value.Equals(@SPANISH_CULTURE, StringComparison.CurrentCultureIgnoreCase) then
				@culture = @SPANISH_CULTURE
			elsif value.Equals(@FRENCH_CULTURE, StringComparison.CurrentCultureIgnoreCase) then
				@culture = @FRENCH_CULTURE
			end
		end
 # <summary>
		# Create activity object from Activity XML, determining the derived type.
		# This is useful when deserializing activity XML of an unknown concrete type.
		# </summary>
		# <param name="activityElement"></param>
		# <returns></returns>
		def Activity.CreateInstance(activityElement)
			activity = nil
			# Look for distinquishing elements within the activity XML.
			if activityElement.GetElementsByTagName("DatabaseName")[0] != nil then
				# DatabaseActivity
				activity = DatabaseActivity.new(activityElement)
			elsif activityElement.GetElementsByTagName("CompanyNbr")[0] != nil then
				# CreditUserActivity
				activity = CreditUserActivity.new(activityElement)
			elsif activityElement.GetElementsByTagName("VendorId")[0] != nil then
				# VendorActivity
				activity = VendorActivity.new(activityElement)
			else
				raise CommonException.new(System::String.Format("Unrecognized activity XML: {0}", activityElement.OuterXml))
			end
			return activity
		end
	end
	class CreditUserActivity < Activity
		def CenterNbr
		end

		def CenterNbr=(value)
		end

		def CompanyNbr
		end

		def CompanyNbr=(value)
		end

		# <summary>
		# Credit user activity context
		# </summary>
		# <summary>
		# Accessor for CenterNbr
		# </summary>
		# <summary>
		# Accessor for CompanyNbr.
		# </summary>
		# <summary>
		# Constructs CreditUserActivity for OLTP activity.
		# </summary>
		def initialize(activityElement)
			# <summary>
			# Constructs CreditUserActivity (for OLTP activity) with Center Number.
			# </summary>
			# <summary>
			# Constructs a CreditUserActivity with a specific ActivityType.
			# </summary>
			# <summary>
			# Constructs a CreditUserActivity with a specific Center Number, Activity Type and Culture.  The
			# default Culture is us-EN (English) and the default ActivityType is OLTP.
			# </summary>
			# <summary>
			# Construct a CreditUserActivity with a specific Center Number, Activity ID and Culture.  The
			# default Culture is us-EN (English) and the default is to create a new Activity ID.
			# </summary>
			# <summary>
			# Constructs CreditUserActivity (for OLTP activity) from UserContext
			# </summary>
			# <param name="userContext">User Context</param>
			# <summary>
			# Constructs CreditUserActivity from UserContext and ActivityType
			# </summary>
			# <param name="userContext">User Context</param>
			# <param name="activityType">Activity Type</param>
			# <summary>
			# Constructor taking XmlElement of serialized activity.
			# </summary>
			# Required elements.
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.CompanyNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CompanyNbr")[0].InnerText)
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			rescue NullReferenceException =>
				#The XmlElement is not a valid Activity
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			ensure
			end
			# Optional elements.
			if activityElement.GetElementsByTagName("CenterNbr")[0] != nil then
				self.CenterNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CenterNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.CompanyNbr < 1 then
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.CompanyNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CompanyNbr")[0].InnerText)
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			ensure
			end
			if activityElement.GetElementsByTagName("CenterNbr")[0] != nil then
				self.CenterNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CenterNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.CompanyNbr < 1 then
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.CompanyNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CompanyNbr")[0].InnerText)
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			ensure
			end
			if activityElement.GetElementsByTagName("CenterNbr")[0] != nil then
				self.CenterNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CenterNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.CompanyNbr < 1 then
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.CompanyNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CompanyNbr")[0].InnerText)
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			ensure
			end
			if activityElement.GetElementsByTagName("CenterNbr")[0] != nil then
				self.CenterNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CenterNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.CompanyNbr < 1 then
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.CompanyNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CompanyNbr")[0].InnerText)
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			ensure
			end
			if activityElement.GetElementsByTagName("CenterNbr")[0] != nil then
				self.CenterNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CenterNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.CompanyNbr < 1 then
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.CompanyNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CompanyNbr")[0].InnerText)
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			ensure
			end
			if activityElement.GetElementsByTagName("CenterNbr")[0] != nil then
				self.CenterNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CenterNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.CompanyNbr < 1 then
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.CompanyNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CompanyNbr")[0].InnerText)
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			ensure
			end
			if activityElement.GetElementsByTagName("CenterNbr")[0] != nil then
				self.CenterNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CenterNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.CompanyNbr < 1 then
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.CompanyNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CompanyNbr")[0].InnerText)
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			ensure
			end
			if activityElement.GetElementsByTagName("CenterNbr")[0] != nil then
				self.CenterNbr = Convert.ToInt32(activityElement.GetElementsByTagName("CenterNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.CompanyNbr < 1 then
				raise CommonException.new(System::String.Format("Invalid CreditUserActivity({0}, {1}, {2})", self.DomainName, self.CompanyNbr, self.UserId))
			end
		end
	end
	class DatabaseActivity < Activity
		def DatabaseName
		end

		def DatabaseName=(value)
		end

		# <summary>
		# Database activity context
		# </summary>
		# <summary>
		# Accessor for DatabaseName
		# </summary>
		# <summary>
		# Initializes with minimum values for completeness.
		# </summary>
		def initialize(activityElement)
			# <summary>
			# Initializes with specified UserId.
			# </summary>
			# <summary>
			# Initializes with specified UserId and ActivityID.
			# </summary>
			# <summary>
			# Constructor taking XmlElement of serialized activity.
			# </summary>
			begin
				# Required elements.
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.DatabaseName = activityElement.GetElementsByTagName("DatabaseName")[0].InnerText
			rescue NullReferenceException =>
				#The XmlElement is not a valid Activity
				raise CommonException.new(System::String.Format("Invalid DatabaseActivity({0}, {1})", self.DomainName, self.DatabaseName))
			ensure
			end
			# Optional elements.
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("UserId")[0] != nil then
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.DatabaseName == "" then
				raise CommonException.new(System::String.Format("Invalid DatabaseActivity({0}, {1})", self.DomainName, self.DatabaseName))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.DatabaseName = activityElement.GetElementsByTagName("DatabaseName")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid DatabaseActivity({0}, {1})", self.DomainName, self.DatabaseName))
			ensure
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("UserId")[0] != nil then
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.DatabaseName == "" then
				raise CommonException.new(System::String.Format("Invalid DatabaseActivity({0}, {1})", self.DomainName, self.DatabaseName))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.DatabaseName = activityElement.GetElementsByTagName("DatabaseName")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid DatabaseActivity({0}, {1})", self.DomainName, self.DatabaseName))
			ensure
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("UserId")[0] != nil then
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.DatabaseName == "" then
				raise CommonException.new(System::String.Format("Invalid DatabaseActivity({0}, {1})", self.DomainName, self.DatabaseName))
			end
		end

		def initialize(activityElement)
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.DatabaseName = activityElement.GetElementsByTagName("DatabaseName")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid DatabaseActivity({0}, {1})", self.DomainName, self.DatabaseName))
			ensure
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("UserId")[0] != nil then
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.DatabaseName == "" then
				raise CommonException.new(System::String.Format("Invalid DatabaseActivity({0}, {1})", self.DomainName, self.DatabaseName))
			end
		end
	end
	class VendorActivity < Activity
		# <summary>
		# Vendor activity context
		# </summary>
		def VendorActivity.LogonUser(lpszUsername, lpszDomain, lpszPassword, dwLogonType, dwLogonProvider, phToken)
		end

		def VendorActivity.CloseHandle(handle)
		end

		def VendorId
		end

		def VendorId=(value)
		end

		def VendorClientNbr
		end

		def VendorClientNbr=(value)
		end

		def ProductCode
		end

		def ProductCode=(value)
		end

		def VendorClientAttributes # Null value means that Impersonation is disabled!
			# <summary>
			# Accessor for VendorId.
			# </summary>
			# <summary>
			# Accessor for VendorClientNbr.
			# </summary>
			# <summary>
			# Accessor for ProductCode.
			# </summary>
			# <summary>
			# Accessor for VendorClientAttributes
			# </summary>
			# Lookup
			if @vendorClientAttr == "" then
				@vendorClientAttr = self.GetVendorClientAttributes()
			end
			return @vendorClientAttr
		end

		def VendorClientAttributes=(value)
			@vendorClientAttr = value
		end

		def DealerId
		end

		def DealerId=(value)
		end

		def ChannelId
		end

		def ChannelId=(value)
		end

		# <summary>
		# Accessor for DealerId
		# </summary>
		# <summary>
		# This method will return channel id.
		# </summary>
		# <summary>
		# Initializes with minimal values for completeness.
		# </summary>
		# <param name="domainName"></param>
		# <param name="vendorId"></param>
		# <param name="vendorClientNbr"></param>
		# <param name="dealerId">If a dealer number is not available, please pass an empty string
		# NOTE: IF YOU PASS AN EMPTY STRING, YOU WILL GET THE DEFAULT CENTER ASSOCIATED WITH THE
		# COMPANY AND FINANCE SOURCE...THIS SHOULD NOT BE USED WHEN ATTEMPTING TO PARSE A CREDIT
		# APPLICATION</param>
		def initialize(activityElement)
			@vendorClientAttr = ""
			@LOGON32_PROVIDER_DEFAULT = 0
			@LOGON32_LOGON_INTERACTIVE = 2
			@credentials = nil
			# <summary>
			# Initializes with a specified ProductCode
			# </summary>
			# <param name="domainName"></param>
			# <param name="vendorId"></param>
			# <param name="vendorClientNbr"></param>
			# <param name="productCode"></param>
			# <param name="dealerId">If a dealer number is not available, please pass an empty string
			# NOTE: IF YOU PASS AN EMPTY STRING, YOU WILL GET THE DEFAULT CENTER ASSOCIATED WITH THE
			# COMPANY AND FINANCE SOURCE...THIS SHOULD NOT BE USED WHEN ATTEMPTING TO PARSE A CREDIT
			# APPLICATION</param>
			# <summary>
			# Constructor taking XmlElement of serialized activity.
			# </summary>
			begin
				# Required elements.
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.VendorId = activityElement.GetElementsByTagName("VendorId")[0].InnerText
				self.VendorClientNbr = activityElement.GetElementsByTagName("VendorClientNbr")[0].InnerText
				self.DealerId = activityElement.GetElementsByTagName("DealerId")[0].InnerText
			rescue NullReferenceException =>
				#The XmlElement is not a valid Activity
				raise CommonException.new(System::String.Format("Invalid VendorActivity - Activity Element Not Initialized(Domain:{0},Vendor ID:{1},Vendor Client:{2},Dealer ID:{3})", self.DomainName, self.VendorId, self.VendorClientNbr, self.DealerId))
			ensure
			end
			# Optional elements.
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("UserId")[0] != nil then
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			end
			if activityElement.GetElementsByTagName("ProductCode")[0] != nil then
				self.ProductCode = activityElement.GetElementsByTagName("ProductCode")[0].InnerText
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.VendorId == "" or self.VendorClientNbr == "" then
				raise CommonException.new(System::String.Format("Invalid VendorActivity - Required Parameter Is An Empty String(Domain:{0},Vendor ID:{1},Vendor Client:{2})", self.DomainName, self.VendorId, self.VendorClientNbr))
			end
		end

		def initialize(activityElement)
			@vendorClientAttr = ""
			@LOGON32_PROVIDER_DEFAULT = 0
			@LOGON32_LOGON_INTERACTIVE = 2
			@credentials = nil
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.VendorId = activityElement.GetElementsByTagName("VendorId")[0].InnerText
				self.VendorClientNbr = activityElement.GetElementsByTagName("VendorClientNbr")[0].InnerText
				self.DealerId = activityElement.GetElementsByTagName("DealerId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid VendorActivity - Activity Element Not Initialized(Domain:{0},Vendor ID:{1},Vendor Client:{2},Dealer ID:{3})", self.DomainName, self.VendorId, self.VendorClientNbr, self.DealerId))
			ensure
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("UserId")[0] != nil then
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			end
			if activityElement.GetElementsByTagName("ProductCode")[0] != nil then
				self.ProductCode = activityElement.GetElementsByTagName("ProductCode")[0].InnerText
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.VendorId == "" or self.VendorClientNbr == "" then
				raise CommonException.new(System::String.Format("Invalid VendorActivity - Required Parameter Is An Empty String(Domain:{0},Vendor ID:{1},Vendor Client:{2})", self.DomainName, self.VendorId, self.VendorClientNbr))
			end
		end

		def initialize(activityElement)
			@vendorClientAttr = ""
			@LOGON32_PROVIDER_DEFAULT = 0
			@LOGON32_LOGON_INTERACTIVE = 2
			@credentials = nil
			begin
				self.DomainName = activityElement.GetElementsByTagName("DomainName")[0].InnerText
				self.VendorId = activityElement.GetElementsByTagName("VendorId")[0].InnerText
				self.VendorClientNbr = activityElement.GetElementsByTagName("VendorClientNbr")[0].InnerText
				self.DealerId = activityElement.GetElementsByTagName("DealerId")[0].InnerText
			rescue NullReferenceException =>
				raise CommonException.new(System::String.Format("Invalid VendorActivity - Activity Element Not Initialized(Domain:{0},Vendor ID:{1},Vendor Client:{2},Dealer ID:{3})", self.DomainName, self.VendorId, self.VendorClientNbr, self.DealerId))
			ensure
			end
			if activityElement.GetElementsByTagName("SystemNbr")[0] != nil then
				self.SystemNbr = Convert.ToInt32(activityElement.GetElementsByTagName("SystemNbr")[0].InnerText)
			end
			if activityElement.GetElementsByTagName("ActivityType")[0] != nil then
				activityTypeString = activityElement.GetElementsByTagName("ActivityType")[0].InnerText
				self.ActivityType = Enum.Parse(ActivityType.to_clr_type, activityTypeString, true)
			end
			if activityElement.GetElementsByTagName("UserId")[0] != nil then
				self.UserId = activityElement.GetElementsByTagName("UserId")[0].InnerText
			end
			if activityElement.GetElementsByTagName("ProductCode")[0] != nil then
				self.ProductCode = activityElement.GetElementsByTagName("ProductCode")[0].InnerText
			end
			if activityElement.GetElementsByTagName("Culture")[0] != nil then
				self.Culture = activityElement.GetElementsByTagName("Culture")[0].InnerText
			end
			if self.DomainName == "" or self.VendorId == "" or self.VendorClientNbr == "" then
				raise CommonException.new(System::String.Format("Invalid VendorActivity - Required Parameter Is An Empty String(Domain:{0},Vendor ID:{1},Vendor Client:{2})", self.DomainName, self.VendorId, self.VendorClientNbr))
			end
		end

		# <summary>
		# Coerces VendorActivity to CreditUserActivity.
		# Performs lookup of VENDOR_CLIENT and/or VENDOR_CLIENT_PRODUCT tables
		# to resolve to a CreditUserActivity context
		# NOTE: If dealer ID is not initialized in the vendor activity context,
		# you will get the default credit center associated with the vendor ID,
		# vendor client number and finance source in table VENDOR_CIENT_PRODUCT.
		# When parsing an incoming application request, you MUST value the dealer ID
		# so that the application can be associated with the correct credit center
		# </summary>
		# <param name="UserActivityType">User activity type</param>
		# <returns>Overriden user activity object</returns>
		def CoerceToUserActivity(UserActivityType)
			coerceVendorUserActivity = System::String.Empty
			userContext = nil
			begin
				if SecurityManager.GetUserContext() != nil then
					raise MethodAccessException.new("Method can not be used from Web Application")
				end
				sqlDatabase = DatabaseFactory.CreateDatabase(DatabaseType.FRAMEWORK.ToString())
				# Lookup the credentials for company zero.
				@credentials = Configuration.GetCrediantials(0)
				begin # ****************************** Impersonation START ******************************
					# ALL THE CODE IN THIS BLOCK *MUST* LIVE WITHIN THIS PUBLIC METHOD (MARKED AS
					# UNSAFE) SO THAT THE DATABASE CALLS OCCUR BETWEEN THE .Impersonate() and .Undo()
					# CALLS.  OTHERWISE, THE IMPERSONATTION WILL NOT OCCUR.  SO, THIS CODE MUST NEVER
					# BE PLACE INTO A PRIVATE METHOD.
					if @credentials != nil then
						tokenHandle = IntPtr.new(0)
						tokenHandle = IntPtr.Zero
						# Call LogonUser to obtain a handle to an access token.
						returnUserValue = self.LogonUser(@credentials.UserId, @credentials.Domain, @credentials.Password, @LOGON32_LOGON_INTERACTIVE, @LOGON32_PROVIDER_DEFAULT, tokenHandle)
						if false == returnUserValue then
							winError = Marshal.GetLastWin32Error()
							raise Win32Exception.new(winError)
						end
						# Use the token handle returned by LogonUser.
						newIdentity = WindowsIdentity.new(tokenHandle)
						userContext = newIdentity.Impersonate()
						# Free the tokens.
						if tokenHandle != IntPtr.Zero then
							self.CloseHandle(tokenHandle)
						end
						# If we have credentials and FromCache=false, then we want to validate that impersonation is working!
						if not @credentials.FromCache then
							impersonatedUser = @credentials.Domain + "\\" + @credentials.UserId
							# IT'S CRITICAL THAT THIS CALL OCCURS WITHIN THIS BLOCK OF CODE.
							dbCmd = sqlDatabase.GetSqlStringCommand("SELECT SYSTEM_USER")
							sqlUser = sqlDatabase.ExecuteScalar(dbCmd)
							if sqlUser.ToLower() != impersonatedUser.ToLower() then
								raise CommonException.new(System::String.Format("Impersonation credentials ({0}) do not match database credentials ({1}).  When impersonation is enabled in Domain.config, database connection strings must be configured with 'Trusted_Connection=True'.", impersonatedUser, sqlUser))
							end
						end
					end
					# ****************************** Impersonation END ******************************
					db = sqlDatabase.GetStoredProcCommand("Fiserv_Common_CoerceVendorToUserActivity")
					sqlDatabase.AddInParameter(db, "@vendorId", SqlDbType.VarChar, self.VendorId)
					sqlDatabase.AddInParameter(db, "@vendorClientNbr", SqlDbType.VarChar, self.VendorClientNbr)
					sqlDatabase.AddInParameter(db, "@productCode", SqlDbType.VarChar, self.ProductCode)
					returnValue = sqlDatabase.ExecuteScalar(db)
					if returnValue != nil then
						coerceVendorUserActivity = returnValue.ToString()
					end
				ensure
					# End impersonation.
					if userContext != nil then
						userContext.Undo()
					end
				end
				success = Int32.TryParse(Utilities.GetInnerXML(coerceVendorUserActivity, "compNbr"), compNbr)
				if not success then
					if Utilities.GetInnerXML(coerceVendorUserActivity, "compNbr") == nil then
						raise ArgumentException.new("Attempted conversion of company '{0}' failed.", compNbr.ToString())
					end
				end
				success = Int32.TryParse(Utilities.GetInnerXML(coerceVendorUserActivity, "centerNbr"), centerNbr)
				if not success then
					if Utilities.GetInnerXML(coerceVendorUserActivity, "centerNbr") == nil then
						raise ArgumentException.new("Attempted conversion of center number '{0}' failed.", centerNbr.ToString())
					end
				end
				userId = Utilities.GetInnerXML(coerceVendorUserActivity, "userId")
				if compNbr == 0 or centerNbr == 0 or System::String.IsNullOrEmpty(userId) then
					raise ArgumentException.new("Invalid values for compNbr, centerNbr or userId")
				end
				# Assign the channel ID to the vendor activity context
				success = Int32.TryParse(Utilities.GetInnerXML(coerceVendorUserActivity, "channelid"), channelId)
				if success then
					self.ChannelId = channelId
				end
				# If dealer ID is provided, we'll look up the correct center based on the dealer ID in the
				# vendor's message.
				if self.DealerId != "" then
					# We have to return to the credit database to fetch the center number that
					# the dealer belongs to
					sqlDatabase = DatabaseFactory.CreateDatabase("Company" + compNbr.ToString())
					# Lookup the credentials for this company.
					@credentials = Configuration.GetCrediantials(compNbr)
					begin # ****************************** Impersonation START ******************************
						# ALL THE CODE IN THIS BLOCK *MUST* LIVE WITHIN THIS PUBLIC METHOD (MARKED AS
						# UNSAFE) SO THAT THE DATABASE CALLS OCCUR BETWEEN THE .Impersonate() and .Undo()
						# CALLS.  OTHERWISE, THE IMPERSONATTION WILL NOT OCCUR.  SO, THIS CODE MUST NEVER
						# BE PLACE INTO A PRIVATE METHOD.
						if @credentials != nil then
							tokenHandle = IntPtr.new(0)
							tokenHandle = IntPtr.Zero
							# Call LogonUser to obtain a handle to an access token.
							returnUserValue = self.LogonUser(@credentials.UserId, @credentials.Domain, @credentials.Password, @LOGON32_LOGON_INTERACTIVE, @LOGON32_PROVIDER_DEFAULT, tokenHandle)
							if false == returnUserValue then
								winError = Marshal.GetLastWin32Error()
								raise Win32Exception.new(winError)
							end
							# Use the token handle returned by LogonUser.
							newIdentity = WindowsIdentity.new(tokenHandle)
							userContext = newIdentity.Impersonate()
							# Free the tokens.
							if tokenHandle != IntPtr.Zero then
								self.CloseHandle(tokenHandle)
							end
							# If we have credentials and FromCache=false, then we want to validate that impersonation is working!
							if not @credentials.FromCache then
								impersonatedUser = @credentials.Domain + "\\" + @credentials.UserId
								# IT'S CRITICAL THAT THIS CALL OCCURS WITHIN THIS BLOCK OF CODE.
								dbCmd = sqlDatabase.GetSqlStringCommand("SELECT SYSTEM_USER")
								sqlUser = sqlDatabase.ExecuteScalar(dbCmd)
								if sqlUser.ToLower() != impersonatedUser.ToLower() then
									raise CommonException.new(System::String.Format("Impersonation credentials ({0}) do not match database credentials ({1}).  When impersonation is enabled in Domain.config, database connection strings must be configured with 'Trusted_Connection=True'.", impersonatedUser, sqlUser))
								end
							end
						end
						# ****************************** Impersonation END ******************************
						dbCommand = sqlDatabase.GetStoredProcCommand("Fiserv_Common_GetCenterNumberFromDealerId")
						sqlDatabase.AddInParameter(dbCommand, "@compNbr", SqlDbType.Int, compNbr)
						sqlDatabase.AddInParameter(dbCommand, "@dealerId", SqlDbType.VarChar, self.DealerId)
						sqlDatabase.AddInParameter(dbCommand, "@productCode", SqlDbType.VarChar, self.ProductCode)
						sqlDatabase.AddInParameter(dbCommand, "@financeSourceId", SqlDbType.VarChar, self.VendorClientNbr)
						sqlDatabase.AddInParameter(dbCommand, "@vendorId", SqlDbType.VarChar, self.VendorId)
						centerNbrFromLosDatabase = sqlDatabase.ExecuteScalar(dbCommand)
						if centerNbrFromLosDatabase != nil and not centerNbrFromLosDatabase.Equals(0) then
							# Update center number initialized above.
							centerNbr = centerNbrFromLosDatabase
						end
					ensure
						# End impersonation.
						if userContext != nil then
							userContext.Undo()
						end
					end
				end
				# Use the longest constructur to build a complete new class
				return CreditUserActivity.new(self.DomainName, compNbr, centerNbr, userId, self.ActivityType.Oltp, self.Culture, self.ActivityId)
			rescue Exception => e
				raise CommonException.new("Failed to coerce VendorActivity to CreditUserActivity: " + e.Message)
			ensure
			end
		end

		# <summary>
		# Get vendor client attributes
		# ToDo: refactor this, because the procedure can run in FRAMEWORK unless it can
		# use an indexed view to get to CREDIT databases to resolve vendor_id!!
		# </summary>
		# <returns></returns>
		def GetVendorClientAttributes()
			userContext = nil
			begin
				if SecurityManager.GetUserContext() != nil then
					raise MethodAccessException.new("Method can not be used from Web Application")
				end
				sqlDatabase = DatabaseFactory.CreateDatabase(DatabaseType.FRAMEWORK.ToString())
				# Lookup the credentials for company zero
				@credentials = Configuration.GetCrediantials(0)
				attributes = nil
				begin # ****************************** Impersonation START ******************************
					# ALL THE CODE IN THIS BLOCK *MUST* LIVE WITHIN THIS PUBLIC METHOD (MARKED AS
					# UNSAFE) SO THAT THE DATABASE CALLS OCCUR BETWEEN THE .Impersonate() and .Undo()
					# CALLS.  OTHERWISE, THE IMPERSONATTION WILL NOT OCCUR.  SO, THIS CODE MUST NEVER
					# BE PLACE INTO A PRIVATE METHOD.
					if @credentials != nil then
						tokenHandle = IntPtr.new(0)
						tokenHandle = IntPtr.Zero
						# Call LogonUser to obtain a handle to an access token.
						returnUserValue = self.LogonUser(@credentials.UserId, @credentials.Domain, @credentials.Password, @LOGON32_LOGON_INTERACTIVE, @LOGON32_PROVIDER_DEFAULT, tokenHandle)
						if false == returnUserValue then
							winError = Marshal.GetLastWin32Error()
							raise Win32Exception.new(winError)
						end
						# Use the token handle returned by LogonUser.
						newIdentity = WindowsIdentity.new(tokenHandle)
						userContext = newIdentity.Impersonate()
						# Free the tokens.
						if tokenHandle != IntPtr.Zero then
							self.CloseHandle(tokenHandle)
						end
						# If we have credentials and FromCache=false, then we want to validate that impersonation is working!
						if not @credentials.FromCache then
							impersonatedUser = @credentials.Domain + "\\" + @credentials.UserId
							# IT'S CRITICAL THAT THIS CALL OCCURS WITHIN THIS BLOCK OF CODE.
							dbCmd = sqlDatabase.GetSqlStringCommand("SELECT SYSTEM_USER")
							sqlUser = sqlDatabase.ExecuteScalar(dbCmd)
							if sqlUser.ToLower() != impersonatedUser.ToLower() then
								raise CommonException.new(System::String.Format("Impersonation credentials ({0}) do not match database credentials ({1}).  When impersonation is enabled in Domain.config, database connection strings must be configured with 'Trusted_Connection=True'.", impersonatedUser, sqlUser))
							end
						end
					end
					# ****************************** Impersonation END ******************************
					dbCommand = sqlDatabase.GetStoredProcCommand("Fiserv_FW_GetVendorAttributes")
					sqlDatabase.AddInParameter(dbCommand, "@vendorId", SqlDbType.VarChar, self.VendorId)
					sqlDatabase.AddInParameter(dbCommand, "@vendorClientNbr", SqlDbType.VarChar, self.VendorClientNbr)
					attributes = sqlDatabase.ExecuteScalar(dbCommand)
				ensure
					# End impersonation.
					if userContext != nil then
						userContext.Undo()
					end
				end
				# Check the ret
				if attributes == nil then
					return ""
				end
				return attributes.ToString()
			rescue Exception => e
				raise CommonException.new("Failed to get the vendor client attributes(" + self.VendorId + ";" + self.VendorClientNbr + "):" + e.Message)
			ensure
			end
		end
	end
end