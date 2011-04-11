<cfsetting enablecfoutputonly="true">

<cfoutput>

<cfinclude template="css.cfm">

<h1>reCAPTCHA on Wheels v1.1.3</h1>
<p>With 2 simple functions, you can use Google's <a href="http://recaptcha.net/">reCAPTCHA</a> service to provide a <acronym title="Completely Automated Turing Test To Tell Computers and Humans Apart">CAPTCHA</acronym> validation to your forms. reCAPTCHA is unique in that users solving the <acronym title="Completely Automated Turing Test To Tell Computers and Humans Apart">CAPTCHA</acronym>s are helping universities and services like Google Book Search scan words from books that weren't picked up properly by <abbr title="Optical Character Recognition">OCR</abbr> technology.</p>

<h2>How to Use</h2>
<p>There are 3 components to using reCAPTCHA in your Wheels application:</p>
<ul>
	<li>Configuration</li>
	<li>Display of the reCAPTCHA widget</li>
	<li>Validation of user input</li>
</ul>

<h2>1. Configuration</h2>
<p>First, you need to <a href="https://admin.recaptcha.net/accounts/login/?next=/recaptcha/createsite/">obtain an <abbr title="Application Programming Interface">API</abbr> key</a> from reCAPTCHA.net. You'll need to set up keys for each of your environments, so you may need one for your development domain and your production domain, for example.</p>
<p>Once you obtain public and private keys, you should set these values in your different environments' config files (<kbd>config/design/settings.cfm</kbd>, <kbd>config/production/settings.cfm</kbd>, etc.):</p>
<pre>
&lt;--- Replace values with the keys assigned to you ---&gt;
&lt;cfset application.reCaptcha.publicKey = &quot;<strong>OEMy3RGbcwAAAAAAC0zu2ztLCSEHeoiOt6LfJpAU</strong>&quot;&gt;
&lt;cfset application.reCaptcha.privateKey = &quot;<strong>F2IANxAfzJAu6LApgLb65q_F0hP6LAAAUAX1A-hV</strong>&quot;&gt;
</pre>
<p>If you prefer setting your custom configurations in <kbd>events/onapplicationstart.cfm</kbd> instead, you could also create code similar to this in that file:</p>
<pre>
&lt;--- reCAPTCHA ---&gt;
&lt;cfswitch expression=&quot;##get('environment')##&quot;&gt;
    &lt;cfcase value=&quot;design&quot;&gt;
        &lt;cfset application.reCaptcha.publicKey = &quot;OEMy3RGbcwAAAAAAC0zu2ztLCSEHeoiOt6LfJpAU&quot;&gt;
        &lt;cfset application.reCaptcha.privateKey = &quot;F2IANxAfzJAu6LApgLb65q_F0hP6LAAAUAX1A-hV&quot;&gt;
    &lt;/cfcase&gt;
    &lt;cfcase value=&quot;production&quot;&gt;
        &lt;cfset application.reCaptcha.publicKey = &quot;RGbcwtLCOEMyAiOtAA6LfJpAUAC0zu2z3SEAAHeo&quot;&gt;
        &lt;cfset application.reCaptcha.privateKey = &quot;Au6LApghP6LAAAUX1A-LF2AfzJAb60hVIAN5q_Fx&quot;&gt;
    &lt;/cfcase&gt;
&lt;/cfswitch&gt;
</pre>
<p>You could always have <code>cfswitch</code> evaluate the current domain name instead of the Wheels environment too if that's your preference.</p>

<h2>2. Display of the reCAPTCHA Widget</h2>
<p>Just use the <code>showCaptcha()</code> function to display the widget in your form.</p>
<pre>
&lt;--- At top of view ---&gt;
&lt;cfparam name=&quot;captchaError&quot; type=&quot;boolean&quot; default=&quot;false&quot;&gt;

&lt;--- In form ---&gt;
&lt;cfoutput&gt;
##showCaptcha(captchaError=captchaError)##
&lt;/cfoutput&gt;
</pre>
<p>The <code>showCaptcha()</code> function accepts 4 optional arguments.</p>
<table>
	<caption>Arguments for <code>showCaptcha()</code></caption>
	<thead>
		<tr>
			<th>Argument</th>
			<th>Type</th>
			<th>Required</th>
			<th>Default</th>
			<th>Description</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td><code>label</code></td>
			<td>string</td>
			<td><code>false</code></td>
			<td><code>Type the two words:</code></td>
			<td>Label to use for reCAPTCHA field.</td>
		</tr>
		<tr class="highlight">
			<td><code>ssl</code></td>
			<td>boolean</td>
			<td><code>false</code></td>
			<td><code>false</code></td>
			<td>Whether or not your form is served over <abbr title="Secure Socket Layer">SSL</abbr>.</td>
		</tr>
		<tr>
			<td><code>theme</code></td>
			<td>string</td>
			<td><code>false</code></td>
			<td><code>clean</code></td>
			<td>reCAPTCHA theme to use. Choices are <code>clean</code>, <code>red</code>, <code>white</code>, and <code>blackglass</code>.</td>
		</tr>
		<tr class="highlight">
			<td><code>captchaError</code></td>
			<td>boolean</td>
			<td><code>false</code></td>
			<td><code>false</code></td>
			<td>Whether or not the field should be surrounded with <code>&lt;#get(functionName="textField", name="errorElement")# class=&quot;field-with-errors&quot;&gt;</code>. (This <abbr title="Hypertext Markup Language">HTML</abbr> tag is determined by the default setting for <code><a href="http://cfwheels.org/docs/function/textfield">textField()</a></code>'s <code>errorElement</code> argument. See the <em>Function Settings</em> section of the <a href="http://cfwheels.org/docs/chapter/configuration-and-defaults">Configuration and Defaults</a> chapter for more information.)</td>
		</tr>
	</tbody>
</table>

<h3>Live Example of reCAPTCHA Widget</h3>
#showCaptcha()#

<h2>3. Validation of User Input</h2>
<p>You use the <code>validateCaptcha()</code> function within your controller action to validate the user's input. It will return <code>true</code> if the test passed and <code>false</code> if not.</p>
<p>Here is an example:</p>
<pre>
&lt;--- Build comment object ---&gt;
&lt;cfset comment = model(&quot;comment&quot;).new(params.comment)&gt;

&lt;--- If CAPTCHA validated ---&gt;
&lt;cfif validateCaptcha()&gt;
    &lt;cfset comment.save()&gt;
    &lt;cfset flashInsert(success=&quot;Comment submitted successfully.&quot;)&gt;
    &lt;cfset redirectTo(action=&quot;post&quot;)&gt;
&lt;--- CAPTCHA didn't validate ---&gt;
&lt;cfelse&gt;
    &lt;cfset captchaError = true&gt;
    &lt;cfset renderPage(action=&quot;post&quot;)&gt;
&lt;/cfif&gt;
</pre>

<h2>Configuration for Offline Development</h2>
<p>Sometimes you need to run your application without access to the Internet. And the reCAPTCHA widget and validation service both require a connection to the Internet! Maybe you're building your application while on the plane or in the airport.</p>
<p>We have a setting that allows for offline development. In your configuration, simply set <code>application.hasInternetAccess</code> to <code>false</code>.</p>
<p>This will cause reCAPTCHA on Wheels to show this text in place of the widget:</p>
<blockquote>
	<p>[NO INTERNET MODE] reCAPTCHA would go here</p>
</blockquote>
<p>In this mode, the <code>validateCaptcha()</code> function will always return <code>true</code> as well so that reCAPTCHA functionality will not get in the way of testing the rest of your form.</p>
<p>When your application's environment is set to <code>testing</code> or <code>production</code>, this setting will always be overriden to <code>true</code>, so do not fear of accidentally forgetting to change it back to <code>true</code> before deploying to staging or production.</p>

<h2>Credits</h2>
<p>This plugin is based on code from the <a href="http://recaptcha.riaforge.org/">ColdFusion reCAPTCHA tag</a> by Robin Hilliard.</p>

</cfoutput>

<cfsetting enablecfoutputonly="false">