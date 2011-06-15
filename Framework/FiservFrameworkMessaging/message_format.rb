module FiservFrameworkMessaging
	class MessageFormatType
		def initialize()
		end

		# <summary>
		# XML
		# </summary>
		# <summary>
		# SOAP
		# </summary>
		# <summary>
		# None
		# </summary>
	end
	# <summary>
	# SoapMessage format type
	# </summary>
	class MessageSoapFormatType
		def initialize()
		end

		# <summary>
		# No elements within Soap body.
		# </summary>
		# <summary>
		# Soap Exception
		# </summary>
		# <summary>
		# Single XML element within Soap body.
		# </summary>
		# <summary>
		# Not an XML element with Soap body.
		# </summary>
		# <summary>
		# Only Activity element within Soap body.
		# </summary>
		# <summary>
		# Multiple XML elements within Soap body.
		# </summary>
	end
end