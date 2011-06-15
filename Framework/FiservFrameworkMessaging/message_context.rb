require "FiservFrameworkCaching"
require "FiservFrameworkData"
require "FiservFrameworkExceptions"

module FiservFrameworkMessaging
	class MessageContext
		def MessageNamespace
			if @msgInfo != nil then
				return @msgInfo.MessageNamespace
			else
				return ""
			end
		end

		# <summary>
		# Message Schema (full path to schema file)
		# </summary>
		def MessageSchemaPath
			if @msgInfo != nil then
				return @msgInfo.MessageSchemaPath
			else
				return ""
			end
		end

		# <summary>
		# Message Type
		# </summary>
		def MessageType
			if @msgInfo != nil then
				return @msgInfo.MessageType
			else
				return ""
			end
		end

		# <summary>
		# Error Type
		# </summary>
		def ErrorType
			if @msgInfo != nil then
				return @msgInfo.ErrorType
			else
				return ""
			end
		end

		# <summary>
		# Response Message Type
		# </summary>
		def ResponseType
			if @msgInfo != nil then
				return @msgInfo.ResponseType
			else
				return ""
			end
		end

		# <summary>
		# Lookup Message Attribute
		# </summary>
		# <param name="name">Attribute Name</param>
		# <returns></returns>
		def GetMessageAttribute(name)
			if @msgInfo != nil then
				return @msgInfo.GetMessageAttribute(name)
			else
				return ""
			end
		end

		# <summary>
		# Message Format
		# </summary>
		def MessageFormatType
			# Call static method on MessageInfo
			return MessageFormatter.GetMessageFormatType(MessageBody)
		end

		# <summary>
		# Message configuration info (includes msg_type)
		# </summary>
		def MessageInfo
			return @msgInfo
		end

		def MessageInfo=(value)
			@msgInfo = value
		end

		# <summary>
		# Message ID (GUID)
		# </summary>
		def MessageId
		end

		def MessageId=(value)
		end

		# <summary>
		# Raw message, including any possible envelope.
		# </summary>
		def MessageBody
			return @msgBody
		end

		def MessageBody=(value)
			self.SetMessageBody(value)
		end

		# <summary>
		# Message in Stream format.
		# </summary>
		def MessageStream
		end

		def MessageStream=(value)
		end

		def MessageContent
			# <summary>
			# MessageContent is the actual XML message payload (without the SOAP envelope).
			# </summary>
			if @msgContent == "" then
				msgFormatter = MessageFormatter.CreateInstance(@msgBody, true)
				@msgContent = msgFormatter.GetMessageContent()
			end
			return @msgContent
		end

		def MessageContent=(value)
			self.SetMessageContent(value)
		end

		# <summary>
		# Message datetime
		# </summary>
		def MessageDate
		end

		def MessageDate=(value)
		end

		def MessageStatus
		end

		def MessageStatus=(value)
		end

		def ActivityId
		end

		def ActivityId=(value)
		end

		def OneWay
			#OneWay is when response_type is not set and when update_job = 0
			return (@msgInfo.ResponseType == "")
		end

		def ServiceUrl
		end

		def ServiceUrl=(value)
		end

		# <summary>
		# User Id: FiHeader.UserId or Activity.UserId
		# </summary>
		def UserId
		end

		def UserId=(value)
		end

		# <summary>
		# Message Number (available after a message is queued).
		# </summary>
		def MessageNbr
		end

		def MessageNbr=(value)
		end

		# <summary>
		# Company Number
		# </summary>
		def CompanyNbr
		end

		def CompanyNbr=(value)
		end

		# <summary>
		# Application ID
		# </summary>
		def ApplicationId
		end

		def ApplicationId=(value)
		end

		# <summary>
		# Schema Name used by this client -- used for interface-related test/stub processing.
		# </summary>
		def SchemaName
		end

		def SchemaName=(value)
		end

		# <summary>
		# <InterfaceType/> value in MSG_TYPE.msg_attributes
		# </summary>
		def InterfaceType
		end

		def InterfaceType=(value)
		end

		# <summary>
		# If true, then test response is fetched from STUB database.
		# </summary>
		def InterfaceTestMode
		end

		def InterfaceTestMode=(value)
		end

		# <summary>
		# <TestLookupKey/> value in CLIENT_INTERFACE_TYPE.interface_attributes
		# </summary>
		def InterfaceTestLookupKey
		end

		def InterfaceTestLookupKey=(value)
		end

		# <summary>
		# <TestLookupKeySize/> value in CLIENT_INTERFACE_TYPE.interface_attributes
		# </summary>
		def InterfaceTestLookupKeySize
		end

		def InterfaceTestLookupKeySize=(value)
		end

		# <summary>
		# <TestLookupDelayMs/> value in CLIENT_INTERFACE_TYPE.interface_attributes
		# </summary>
		def InterfaceTestLookupDelayMs
		end

		def InterfaceTestLookupDelayMs=(value)
		end
 # <summary>
		# Private constructor to initialize default values
		# </summary>
		def initialize(messageType, messageBody, companyNbr, applicationId)
			@msgInfo = nil
			@msgBody = ""
			@msgContent = ""
			@instanceData = nil
			# <summary>
			# Create a MessageContext instance for a given text message.
			# Message type is resolved from the message body.
			# </summary>
			# <param name="messageBody">Message Body</param>
			# <param name="companyNbr">Company Number (set to 0 if unknown)</param>
			# <param name="applicationId">Application ID (set to 0 if unknown)</param>
			# Set private members.
			# Resolve MessageInfo (from message body)
			# Lookup TestMode flag if <InterfaceType/> MSG_TYPE..message_attribute is available.
			# <summary>
			# Create a MessageContext instance for a given message type and message.
			# </summary>
			# <param name="messageType">Message Type</param>
			# <param name="messageBody">Message Body</param>
			# <param name="companyNbr">Company Number (set to 0 if unknown)</param>
			# <param name="applicationId">Application ID (set to 0 if unknown)</param>
			begin
				# Set private members.
				@msgBody = messageBody
				self.CompanyNbr = companyNbr
				self.ApplicationId = applicationId
				# Resolve MessageInfo (using provided MessageType)
				@msgInfo = MessageInfoManager.BuildMessageInfo(messageType, messageBody)
				# Lookup TestMode flag if <InterfaceType/> MSG_TYPE..message_attribute is available.
				self.ResolveTestAttributes()
			rescue Exception => e
				raise CommonException.new("Failed to create message context for Message Type '" + messageType + "'", e)
			ensure
			end
		end

		def initialize(messageType, messageBody, companyNbr, applicationId)
			@msgInfo = nil
			@msgBody = ""
			@msgContent = ""
			@instanceData = nil
			begin
				@msgBody = messageBody
				self.CompanyNbr = companyNbr
				self.ApplicationId = applicationId
				@msgInfo = MessageInfoManager.BuildMessageInfo(messageType, messageBody)
				self.ResolveTestAttributes()
			rescue Exception => e
				raise CommonException.new("Failed to create message context for Message Type '" + messageType + "'", e)
			ensure
			end
		end

		def initialize(messageType, messageBody, companyNbr, applicationId)
			@msgInfo = nil
			@msgBody = ""
			@msgContent = ""
			@instanceData = nil
			begin
				@msgBody = messageBody
				self.CompanyNbr = companyNbr
				self.ApplicationId = applicationId
				@msgInfo = MessageInfoManager.BuildMessageInfo(messageType, messageBody)
				self.ResolveTestAttributes()
			rescue Exception => e
				raise CommonException.new("Failed to create message context for Message Type '" + messageType + "'", e)
			ensure
			end
		end
 # <summary>
		# Calls Fiserv_Msg_StoreMessage procedure, specifying all optional parameters.
		# Only consumed by MessageProxy for synchronous message processing.
		# </summary>
		def StoreMessage()
			# Call the procedure to queue the message.
			sqlAccess = SqlAccess.new(Configuration.MessageActivity)
			sqlParams = Array.CreateInstance(SqlParameter, 8)
			sqlParams[0] = SqlParameter.new("@msgType", self.MessageType)
			sqlParams[1] = SqlParameter.new("@msgBody", @msgBody)
			sqlParams[2] = SqlParameter.new("@compNbr", self.CompanyNbr)
			sqlParams[3] = SqlParameter.new("@applicationId", self.ApplicationId)
			sqlParams[4] = SqlParameter.new("@activityId", self.ActivityId)
			sqlParams[5] = SqlParameter.new("@msgId", self.MessageId)
			sqlParams[6] = SqlParameter.new("@msgSyncFlag", 1) # Assume synchronous message!
			sqlParams[7] = SqlParameter.new("@msgNbr", SqlDbType.Int)
			sqlParams[7].Direction = ParameterDirection.Output
			sqlAccess.ExecuteNonQuery("Fiserv_Msg_StoreMessage", sqlParams)
			self.MessageNbr = Convert.ToInt32(sqlParams[7].Value)
		end

		# <summary>
		# Calls Fiserv_Msg_QueueMessage procedure, specifying all optional parameters.
		# Only consumed by MessageProxy and ProcessHandler.
		# </summary>
		def QueueMessage()
			# Make sure we have valid message and activity IDs.
			if self.MessageId == "" then
				self.MessageId = Guid.NewGuid().ToString()
			end
			if self.ActivityId == "" then
				self.ActivityId = self.MessageId
			end
			# Call the procedure to queue the message.
			sqlAccess = SqlAccess.new(Configuration.MessageActivity)
			sqlParams = Array.CreateInstance(SqlParameter, 7)
			sqlParams[0] = SqlParameter.new("@msgType", self.MessageType)
			sqlParams[1] = SqlParameter.new("@msgBody", @msgBody)
			sqlParams[2] = SqlParameter.new("@compNbr", self.CompanyNbr)
			sqlParams[3] = SqlParameter.new("@applicationId", self.ApplicationId)
			sqlParams[4] = SqlParameter.new("@activityId", self.ActivityId)
			sqlParams[5] = SqlParameter.new("@msgId", self.MessageId)
			sqlParams[6] = SqlParameter.new("@msgNbr", SqlDbType.Int)
			sqlParams[6].Direction = ParameterDirection.Output
			sqlAccess.ExecuteNonQuery("Fiserv_Msg_QueueMessage", sqlParams)
			self.MessageNbr = Convert.ToInt32(sqlParams[6].Value)
		end
 # <summary>
		# Resolve the TestMode by looking for an InterfaceType message attribute
		# and performing a database lookup.
		# </summary>
		def ResolveTestAttributes()
			# Set the interface type and lookup key
			self.InterfaceType = @msgInfo.GetMessageAttribute("InterfaceType")
			# ToDo!  This is our hack.  If the InterfaceType attribute exists, then we make another
			# database lookup (to the LOS database) to fetch the test_mode value from the CLIENT_INTERFACE_TYPE table.
			if self.InterfaceType != "" then
				# Throw an exception if we don't have CompanyNbr set, because we want to find all
				# places in the code where CompanyNbr == 0.
				if self.CompanyNbr == 0 then
					raise CommonException.new("Cannot resolve InterfaceType parameters, because CompanyNbr is not set")
				end
				sqlAccess = SqlAccess.new(self.GetCreditUserActivity())
				sqlParameters = Array.CreateInstance(SqlParameter, 2)
				sqlParameters[0] = SqlParameter.new("@iCompNbr", self.CompanyNbr)
				sqlParameters[1] = SqlParameter.new("@sInterfaceType", self.InterfaceType)
				interfaceAttributes = sqlAccess.ExecuteDataSet("Fiserv_Common_GetInterfaceTypeAttributes", sqlParameters)
				dataRow = interfaceAttributes.Tables[0].Rows[0]
				if interfaceAttributes.Tables[0].Rows.Count == 0 then
					raise CommonException.new(System::String.Format("Interface attributes not found for Interface Type '{0}' in Company '{1}' for Message Type '{2}'", self.InterfaceType, self.CompanyNbr, self.MessageType))
				end
				self.SchemaName = dataRow["schema_name"].ToString()
				self.InterfaceTestLookupKey = dataRow["test_lookup_key"].ToString()
				self.InterfaceTestLookupKeySize = Convert.ToInt32(dataRow["test_lookup_key_size"])
				self.InterfaceTestLookupDelayMs = Convert.ToInt32(dataRow["test_lookup_delay_ms"])
				if dataRow["test_mode"].ToString() == "1" then
					self.InterfaceTestMode = true
				end
				if self.InterfaceTestLookupKey == "" then
					raise CommonException.new(System::String.Format("InterfaceTestLookupKey attribute not found for Message Type '{0}'", self.MessageType))
				end
			end
		end
 # <summary>
		# Update message body
		# </summary>
		# <param name="messageBody">Message Body</param>
		# <returns>Message Body</returns>
		def SetMessageBody(messageBody)
			# Set message body
			@msgBody = messageBody
			# Reset message content
			@msgContent = ""
			# Update underlying stream
			MessageFormatter.SetMessageStream(@msgBody, self.MessageStream)
			return @msgBody
		end

		# <summary>
		# Update MessageContent (just XML payload).
		# </summary>
		# <param name="messageContent">Message Content</param>
		# <returns></returns>
		def SetMessageContent(messageContent)
			# Set message content and update message body
			@msgContent = messageContent
			msgFormatter = MessageFormatter.CreateInstance(@msgBody, self.MessageStream, true)
			@msgBody = msgFormatter.SetMessageContent(messageContent)
			return @msgBody
		end

		# <summary>
		# Update Application ID for this message.
		# </summary>
		# <param name="applicationId">Application ID</param>
		def SetApplicationId(applicationId)
			# Do nothing if there's a match.
			if self.ApplicationId == applicationId then
				return
			end
			# Disallow changes to a good Application ID.
			if self.ApplicationId > 0 then
				raise InvalidOperationException.new("Not allowed to modify application_id if the message already has a non-zero application_id")
			end
			# Disallow a zero or negative new application ID.
			if applicationId <= 0 then
				raise ArgumentException.new("Must provide a positive value for application_id")
			end
			# Update private member.
			self.ApplicationId = applicationId
			begin
				# Update the database
				sqlAccess = SqlAccess.new(Configuration.MessageActivity)
				sqlParams = Array.CreateInstance(SqlParameter, 2)
				sqlParams[0] = SqlParameter.new("@iMsgNbr", self.MessageNbr)
				sqlParams[1] = SqlParameter.new("@iApplId", self.ApplicationId)
				sqlAccess.ExecuteNonQuery("Fiserv_Msg_UpdateMessageApplicationId", sqlParams)
			rescue Exception => e
				raise CommonException.new("Failed to set application_id for msg_nbr = '" + self.MessageNbr + "'", e)
			ensure
			end
		end

		# <summary>
		# Update instance data for this message.
		# </summary>
		# <param name="msgInstanceData">Message Instance Data</param>
		def SetInstanceData(msgInstanceData)
			if @instanceData != msgInstanceData then
				# Update private member.
				@instanceData = msgInstanceData
				begin
					# Update the database
					sqlParameter = Array.CreateInstance(SqlParameter, 2)
					sqlParameter[0] = SqlParameter.new("@msgNbr", self.MessageNbr)
					sqlParameter[1] = SqlParameter.new("@instanceData", msgInstanceData)
					# Execute the sp
					sqlAccess = SqlAccess.new(Configuration.MessageActivity)
					sqlAccess.ExecuteNonQuery("Fiserv_Msg_SetInstanceData", sqlParameter)
				rescue Exception => e
					raise CommonException.new("Failed to set message instance data for msg_nbr = '" + self.MessageNbr + "'", e)
				ensure
				end
			end
		end

		# <summary>
		# Fetch instance data for this message.
		# </summary>
		# <returns>Instance Data</returns>
		def GetInstanceData()
			# Read the database if our private variable is null.
			if @instanceData == nil then
				begin
					# Read the database.
					sqlParameter = Array.CreateInstance(SqlParameter, 1)
					sqlParameter[0] = SqlParameter.new("@msgNbr", self.MessageNbr)
					# Execute the sp
					sqlAccess = SqlAccess.new(Configuration.MessageActivity)
					@instanceData = sqlAccess.ExecuteScalar("Fiserv_Msg_GetInstanceData", sqlParameter)
				rescue Exception => e
					raise CommonException.new("Failed to get message instance data for msg_nbr = '" + self.MessageNbr + "'", e)
				ensure
				end
			end
			return @instanceData
		end

		# <summary>
		# Build and return CreditUserActivity from the state of this object.
		# </summary>
		# <returns></returns>
		def GetCreditUserActivity()
			creditActivity = nil
			if self.CompanyNbr > 0 then
				creditActivity = CreditUserActivity.new(Configuration.DomainName, self.CompanyNbr, self.UserId)
				creditActivity.ActivityId = self.ActivityId
			end
			return creditActivity
		end

		# <summary>
		# Fetch the last initialized instance data related to the message context's activity ID
		# </summary>
		# <returns>Instance Data</returns>
		def GetActivityRelatedInstanceData()
			# Read the database if our private variable is null.
			if @instanceData == nil then
				begin
					# Read the database.
					sqlParameter = Array.CreateInstance(SqlParameter, 1)
					sqlParameter[0] = SqlParameter.new("@msgActivityId", self.ActivityId)
					# Execute the sp
					sqlAccess = SqlAccess.new(Configuration.MessageActivity)
					@instanceData = sqlAccess.ExecuteScalar("Fiserv_Msg_GetInstanceDataByActivityId", sqlParameter)
				rescue Exception => e
					raise CommonException.new(System::String.Format("Failed to get message instance data for msg_activity_id {0}.", self.ActivityId), e)
				ensure
				end
			end
			return @instanceData
		end

		# <summary>
		# Set message status
		# </summary>
		# <param name="messageStatus"></param>
		def SetMessageStatus(messageStatus)
			# Update private member.
			self.MessageStatus = messageStatus
			begin
				# Update database.
				sqlParameter = Array.CreateInstance(SqlParameter, 4)
				sqlParameter[0] = SqlParameter.new("@msgNbr", self.MessageNbr)
				case self.MessageStatus
					when MessageStatusType.Completed
						sqlParameter[1] = SqlParameter.new("@msgStatus", "C")
					when MessageStatusType.Failed
						sqlParameter[1] = SqlParameter.new("@msgStatus", "E")
					when MessageStatusType.SetupFailure
						sqlParameter[1] = SqlParameter.new("@msgStatus", "F")
					else
						raise CommonException.new(System::String.Format("Invalid action -- cannot set message status to '{0}' within MessageContext object", messageStatus))
				end
				sqlParameter[2] = SqlParameter.new("@companyNbr", self.CompanyNbr)
				sqlParameter[3] = SqlParameter.new("@applicationId", self.ApplicationId)
				# Execute the sp
				sqlAccess = SqlAccess.new(Configuration.MessageActivity)
				sqlAccess.ExecuteNonQuery("Fiserv_Msg_StatusMessage", sqlParameter)
			rescue Exception => e
				raise CommonException.new("Failed to update message status for message type '" + @msgInfo.MessageType + "', message ID '" + self.MessageId + "'", e)
			ensure
			end
		end

		# <summary>
		# Set message status in Job step queue
		# </summary>
		def SetJobStepStatus(messageStatus)
			begin
				# Sql parameters
				sqlParameter = Array.CreateInstance(SqlParameter, 3)
				sqlParameter[0] = SqlParameter.new("@jobStepId", self.MessageId)
				case messageStatus
					when MessageStatusType.Completed
						sqlParameter[1] = SqlParameter.new("@jobStepStatus", "C")
					when MessageStatusType.Failed
						sqlParameter[1] = SqlParameter.new("@jobStepStatus", "E")
					else
						raise CommonException.new(System::String.Format("Invalid action -- cannot set job step status to '{0}' within MessageContext object", messageStatus))
				end
				sqlParameter[2] = SqlParameter.new("@jobDocument", @msgBody)
				# Execute the sp
				sqlAccess = SqlAccess.new(Configuration.MessageActivity)
				sqlAccess.ExecuteNonQuery("Fiserv_Msg_UpdateJobStepStatus", sqlParameter)
			rescue Exception => e
				raise CommonException.new("Failed to update step status in job queue(JobStepType=" + @msgInfo.MessageType + "; JobStepID=" + self.MessageId + ")", e)
			ensure
			end
		end

		# <summary>
		# Set message status as Suspended
		# </summary>
		# <param name="retryInterval"></param>
		# <param name="retryMaxCount"></param>
		# <returns></returns>
		def SetSuspendStatus(retryInterval, retryMaxCount)
			# Update private member.
			self.MessageStatus = MessageStatusType.Suspended
			begin
				# Update database.
				sqlParameter = Array.CreateInstance(SqlParameter, 3)
				sqlParameter[0] = SqlParameter.new("@msgNbr", self.MessageNbr)
				sqlParameter[1] = SqlParameter.new("@msgRetryInterval", retryInterval)
				sqlParameter[2] = SqlParameter.new("@msgRetryMaxCount", retryMaxCount)
				sqlAccess = SqlAccess.new(Configuration.MessageActivity)
				retryCount = sqlAccess.ExecuteScalar("Fiserv_Msg_StatusMessageAsSuspended", sqlParameter)
				return Convert.ToInt32(retryCount)
			rescue Exception => e
				raise CommonException.new("Failed to update message status as Suspended for message type '" + @msgInfo.MessageType + "', message ID '" + self.MessageId + "'", e)
			ensure
			end
		end

		# <summary>
		# Clone a MessageContext instance
		# </summary>
		# <returns></returns>
		def Clone()
			msgContext = self.MemberwiseClone()
			msgInfo = self.MessageInfo.Clone()
			msgContext.MessageInfo = @msgInfo
			return msgContext
		end

		# <summary>
		# Construct a message context for the response message
		# </summary>
		# <param name="responseMessage">Response Message</param>
		# <returns>Message Context of response message</returns>
		def CreateResponseMessageContext(responseMessage)
			begin
				if System::String.IsNullOrEmpty(responseMessage) or @msgInfo.ResponseType == "" then
					# No message context if response is null or message is one way (no response message)
					return nil
				end
				# Create a response message context for the two-way message
				response_context = MessageContext.new(self.ResponseType, responseMessage, self.CompanyNbr, self.ApplicationId)
				response_context.ActivityId = self.ActivityId
				response_context.UserId = self.UserId
				return response_context
			rescue Exception => e
				raise CommonException.new("Failed to construct the message context for the response", e)
			ensure
			end
		end
	end
end