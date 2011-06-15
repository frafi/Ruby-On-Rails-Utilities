module FiservFrameworkMessaging
	# <summary>
	# Interface defines a .NET worker component executed via the .NET adapter.
	# </summary>
	class IWorker
		# <summary>
		# Execute a worker transaction with a given request message and return the response
		# </summary>
		# <param name="messageContext">Message Context</param>
		def Execute(messageContext)
		end
	end
end