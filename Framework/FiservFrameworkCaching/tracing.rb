require "FiservFrameworkLogging"

module FiservFrameworkCaching
	# <summary>
	# Exposes method to trace events within framework code.  NOT TO BE USED
	# BY APPLICATION CODE.
	# </summary>
	class Tracing
		# <summary>
		# Write information trace message.  ONLY TO BE USED BY FRAMEWORK CODE THAT
		# NEEDS TO SHOW SYSTEM INITIALIZATION PROGRESS.
		# </summary>
		# <param name="message">Message</param>
		def Tracing.WriteEntry(message)
			Tracing.WriteEntry("", message, EventLogEntryType.Information, Log.InformationEventId)
		end

		# <summary>
		# Write information trace message with a specific source.  ONLY TO BE USED BY
		# FRAMEWORK CODE RELATED TO STARTING AND STOPPING WINDOWS SERVICES.
		# </summary>
		# <param name="source">Source (Service Name)</param>
		# <param name="message">Message</param>
		def Tracing.WriteEntry(source, message)
			Tracing.WriteEntry(source, message, EventLogEntryType.Information, Log.InformationEventId)
		end

		# <summary>
		# Write error trace message with specific event ID.  ONLY TO BE USED BY FRAMEWORK
		# CODE THAT NEEDS TO BYPASS NORMAL APPLICATION LOGGING TO SHOW CONFIGURATION
		# PROBLEMS.
		# </summary>
		# <param name="eventId">Event ID</param>
		# <param name="message">Message</param>
		def Tracing.WriteEntry(eventId, message)
			Tracing.WriteEntry("", message, EventLogEntryType.Error, eventId)
		end

		# <summary>
		# Write trace message of specified type.
		# </summary>
		def Tracing.WriteEntry(source, message, eventLogType, eventId)
			begin
				# If the source is not provided, then we lookup the product name.
				if source == "" then
					source = Configuration.ProductName
				end
				# Create the event source if needed.
				if not EventLog.SourceExists(source) then
					EventLog.CreateEventSource(source, "Application")
				end
				# Write the given message to the event log.
				EventLog.WriteEntry(source, message, eventLogType, eventId)
			rescue Exception => ex
				begin
					# Try to log why the above method failed.
					EventLog.WriteEntry("Application", System::String.Format("Fiserv.Framework.Caching.Tracing failed to write to the Application log with a source of '{0}':\n\n", source, ex.Message), EventLogEntryType.Error, 1055)
					# Try to write the given message to the event log.
					EventLog.WriteEntry("Application", message, eventLogType, eventId)
				rescue Exception => ex2
					# Notice that we are logging the error associated with the
					# EventLog failure as well as the original message.
					Tracing.LogToFile(message, ex2.Message, true)
				ensure
				end
			ensure
			end
		end

		# <summary>
		# Last resort for logging an application error and related EventLog error.  ONLY TO BE USED
		# BY FRAMEWORK CODE THAT NEEDS TO SHOW SYSTEM INITIALIZATION PROBLEMS.
		# </summary>
		# <param name="eventMessage">Original Error</param>
		# <param name="eventLogError">EventLog Error</param>
		# <param name="failSilently">If true, this function will not throw any exceptions</param>
		def Tracing.LogToFile(eventMessage, eventLogError, failSilently)
			logFilename = System::String.Empty
			begin
				logFilename = Path.Combine(Configuration.LogPath, Configuration.DomainName + '_' + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".err")
				logFile = File.AppendText(logFilename)
				logFile.WriteLine("===============================================================")
				logFile.WriteLine(eventMessage)
				logFile.WriteLine("===============================================================")
				logFile.WriteLine(eventLogError)
			rescue Exception => ex
				if not failSilently then
					raise Exception.new(System::String.Format("Failed to log file '{0}': {1}", logFilename, ex.Message))
				end
			ensure
			end
		end
	end
end