<cfcomponent mixin="controller" output="false">

	<!----------------------------------------------------->
	
	<cffunction name="init" hint="Constructor.">
	
		<cfset this.version = "1.0,1.0.1,1.0.2,1.0.3,1.0.4,1.0.5,1.1,1.1.1,1.1.2,1.1.3,1.1.4,1.1.5">
		<cfreturn this>
	
	</cffunction>
	
	<!----------------------------------------------------->
	
	<cffunction name="validateCaptcha" returntype="boolean" hint="Processes and verifies a reCAPTCHA entry. Returns true if verification is successful, false if not.">
		<cfargument name="challengeField" type="string" required="false" default="#params.recaptcha_challenge_field#">
		<cfargument name="responseField" type="string" required="false" default="#params.recaptcha_response_field#">
		
		<cfset var loc = {}>
		
		<!--- If we have Internet access, continue with test --->
		<cfif useReCaptcha()>
			<cftry>
				<cfhttp url="http://api-verify.recaptcha.net/verify" result="loc.cfhttp" method="post" timeout="5" throwonerror="true">
					<cfhttpparam type="formfield" name="privatekey" value="#application.reCaptcha.privateKey#">
					<cfhttpparam type="formfield" name="remoteip" value="#cgi.remote_addr#">
					<cfhttpparam type="formfield" name="challenge" value="#arguments.challengeField#">
					<cfhttpparam type="formfield" name="response" value="#arguments.responseField#">
				</cfhttp>
				<cfcatch>
					<cfreturn false>
				</cfcatch>
			</cftry>
		
			<cfset loc.aResponse = ListToArray(loc.cfhttp.FileContent, Chr(10))>
			<cfset params.recaptcha = loc.aResponse[1]>
		
			<cfif
				loc.aResponse[1] is "false"
				and loc.aResponse[2] neq "incorrect-captcha-sol"
			>
				<cfreturn false>
			</cfif>
			
			<cfreturn loc.aResponse[1]>
		<!--- Sometimes we don't have access to the Internet when developing.
				In that case, always return true --->
		<cfelse>
			<cfreturn true>
		</cfif>

	</cffunction>
	
	<!----------------------------------------------------->
	
	<cffunction name="showCaptcha" hint="Displays reCAPTCHA challenge field.">
		<cfargument name="label" type="string" required="false" default="Type the two words:" hint="Label to use for reCAPTCHA field.">
		<cfargument name="ssl" type="boolean" required="false" default="false" hint="Whether or not your form is served over SSL.">
		<cfargument name="theme" type="string" required="false" default="clean" hint="reCAPTCHA theme to use.">
		<cfargument name="captchaError" type="boolean" required="false" default="false" hint="Whether or not the field should be surrounded with the `errorElement` value for the `textField` helper.">
		
		<cfset var loc = {}>
		
		<!--- Sometimes we don't have access to the Internet when developing --->
		<cfif useReCaptcha()>
			<cfif arguments.ssl>
				<cfset loc.challengeUrl = "https://api-secure.recaptcha.net">
			<cfelse>
				<cfset loc.challengeUrl = "http://api.recaptcha.net">
			</cfif>
			
			<cftry>
				<cfoutput>
					<cfif arguments.captchaError><#get(functionName="textField", name="errorElement")# class="field-with-errors"></cfif>
					<div>
						<script type="text/javascript">
						<!--
							var RecaptchaOptions = {
								theme : '#arguments.theme#',
							};
						//-->
						</script>
						<label for="recaptcha_response_field">#arguments.label#</label>
						<script type="text/javascript" src="#loc.challengeUrl#/challenge?k=#application.reCaptcha.publicKey#"></script>
						<noscript>
							<iframe src="#loc.challengeUrl#/noscript?k=#application.reCaptcha.publicKey#" height="300" width="500" frameborder="0"></iframe><br />
							<textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
							<input type="hidden" name="recaptcha_response_field" value="manual_challenge" />
						</noscript>
						
					</div>
					<cfif arguments.captchaError></#get(functionName="textField", name="errorElement")#></cfif>
				</cfoutput>
				<!--- Catch errors --->
				<cfcatch type="any">
					<cfoutput>Error displaying reCAPTCHA. Make sure that you have set values in your config for <code>application.reCaptcha.publicKey</code> and <code>application.reCaptcha.privateKey</code>.</cfoutput>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfoutput>[NO INTERNET MODE] reCAPTCHA would go here</cfoutput>
		</cfif>
	
	</cffunction>
	
	<!----------------------------------------------------->
	
	<cffunction name="useReCaptcha" returntype="boolean" hint="Sometimes we don't have access to the Internet when we're developing or testing. This returns whether or not our app should use reCAPTCHA based on environment and whether or not we have Internet access.">
		
		<cfparam name="application.hasInternetAccess" type="boolean" default="true">
		
		<!--- The hasInternetAccess setting only applies when the environment is not production or testing --->
		<cfif not ListFind("testing,production", get("environment"))>
			<cfreturn application.hasInternetAccess>
		<!--- Always return true in testing or production --->
		<cfelse>
			<cfreturn true>
		</cfif>
	
	</cffunction>
	
	<!----------------------------------------------------->

</cfcomponent>