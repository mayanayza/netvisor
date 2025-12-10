// Email template constants

pub const EMAIL_HEADER: &str = r#"<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NetVisor</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5;">
    <table role="presentation" style="width: 100%; border-collapse: collapse; background-color: #f5f5f5;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table role="presentation" style="max-width: 600px; width: 100%; border-collapse: collapse; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);">
                    <!-- Header with Logo -->
                    <tr>
                        <td align="center" style="padding: 40px 40px 30px 40px;">
                            <img src="https://cdn.jsdelivr.net/gh/selfhst/icons@master/png/netvisor.png" alt="NetVisor" style="width: 80px; height: 80px; display: block;">
                        </td>
                    </tr>
"#;

pub const EMAIL_FOOTER: &str = r#"                    <!-- Footer -->
                    <tr>
                        <td align="center" style="padding: 30px 40px 20px 40px; background-color: #f9fafb; border-radius: 0 0 8px 8px;">
                            <!-- Social Links -->
                            <table role="presentation" style="margin: 0 auto 20px auto; border-collapse: collapse;">
                                <tr>
                                    <td style="padding: 0 10px;">
                                        <a href="https://discord.com/invite/b7ffQr8AcZ" style="display: inline-block;">
                                            <img src="https://cdn.jsdelivr.net/gh/selfhst/icons@master/png/discord.png" alt="Discord" style="width: 24px; height: 24px; display: block;">
                                        </a>
                                    </td>
                                    <td style="padding: 0 10px;">
                                        <a href="https://github.com/netvisor-io/netvisor" style="display: inline-block;">
                                            <img src="https://cdn.jsdelivr.net/gh/selfhst/icons@master/png/github.png" alt="GitHub" style="width: 24px; height: 24px; display: block;">
                                        </a>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin: 0; font-size: 12px; line-height: 18px; color: #9ca3af;">© 2025 NetVisor. All rights reserved.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
"#;

pub const PASSWORD_RESET_TITLE: &str = "NetVisor Password Reset";

pub const PASSWORD_RESET_BODY: &str = r#"                    <!-- Main Content -->
                    <tr>
                        <td style="padding: 0 40px 20px 40px;">
                            <h1 style="margin: 0 0 20px 0; font-size: 24px; font-weight: 600; color: #1a1a1a; text-align: center;">Reset Your Password</h1>
                            <p style="margin: 0 0 20px 0; font-size: 16px; line-height: 24px; color: #4a4a4a;">Hi there,</p>
                            <p style="margin: 0 0 20px 0; font-size: 16px; line-height: 24px; color: #4a4a4a;">We received a request to reset your password for your NetVisor account. Click the button below to create a new password:</p>
                        </td>
                    </tr>
                    
                    <!-- CTA Button -->
                    <tr>
                        <td align="center" style="padding: 0 40px 30px 40px;">
                            <a href="{reset_url}" style="display: inline-block; padding: 14px 40px; background-color: #2563eb; color: #ffffff; text-decoration: none; border-radius: 6px; font-size: 16px; font-weight: 500;">Reset Password</a>
                        </td>
                    </tr>
                    
                    <!-- Alternative Link -->
                    <tr>
                        <td style="padding: 0 40px 20px 40px;">
                            <p style="margin: 0 0 10px 0; font-size: 14px; line-height: 20px; color: #6b7280;">If the button doesn't work, copy and paste this link into your browser:</p>
                            <p style="margin: 0 0 20px 0; font-size: 14px; line-height: 20px; color: #2563eb; word-break: break-all;">{reset_url}</p>
                        </td>
                    </tr>
                    
                    <!-- Security Notice -->
                    <tr>
                        <td style="padding: 0 40px 30px 40px; border-top: 1px solid #e5e7eb;">
                            <p style="margin: 20px 0 0 0; font-size: 14px; line-height: 20px; color: #6b7280;">This password reset link will expire in 24 hours. If you didn't request a password reset, you can safely ignore this email.</p>
                        </td>
                    </tr>
"#;

pub const INVITE_LINK_BODY: &str = r#"                    <!-- Main Content -->
                    <tr>
                        <td style="padding: 0 40px 20px 40px;">
                            <h1 style="margin: 0 0 20px 0; font-size: 24px; font-weight: 600; color: #1a1a1a; text-align: center;">You've Been Invited to NetVisor</h1>
                            <p style="margin: 0 0 20px 0; font-size: 16px; line-height: 24px; color: #4a4a4a;">Hi there,</p>
                            <p style="margin: 0 0 20px 0; font-size: 16px; line-height: 24px; color: #4a4a4a;">{inviter_name} has invited you to join their NetVisor instance to visualize and explore their network infrastructure.</p>
                            <p style="margin: 0 0 20px 0; font-size: 16px; line-height: 24px; color: #4a4a4a;">Click the button below to accept the invitation and create your account:</p>
                        </td>
                    </tr>
                    
                    <!-- CTA Button -->
                    <tr>
                        <td align="center" style="padding: 0 40px 30px 40px;">
                            <a href="{invite_url}" style="display: inline-block; padding: 14px 40px; background-color: #2563eb; color: #ffffff; text-decoration: none; border-radius: 6px; font-size: 16px; font-weight: 500;">Accept Invitation</a>
                        </td>
                    </tr>
                    
                    <!-- Alternative Link -->
                    <tr>
                        <td style="padding: 0 40px 20px 40px;">
                            <p style="margin: 0 0 10px 0; font-size: 14px; line-height: 20px; color: #6b7280;">If the button doesn't work, copy and paste this link into your browser:</p>
                            <p style="margin: 0 0 20px 0; font-size: 14px; line-height: 20px; color: #2563eb; word-break: break-all;">{invite_url}</p>
                        </td>
                    </tr>
                    
                    <!-- Expiration Notice -->
                    <tr>
                        <td style="padding: 0 40px 30px 40px; border-top: 1px solid #e5e7eb;">
                            <p style="margin: 20px 0 0 0; font-size: 14px; line-height: 20px; color: #6b7280;">This invitation link will expire in 7 days. If you didn't expect this invitation, you can safely ignore this email.</p>
                        </td>
                    </tr>
"#;
