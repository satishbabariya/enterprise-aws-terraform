resource "aws_sesv2_email_identity" "this" {
  email_identity = var.domain

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }

  tags = var.tags
}

# DKIM CNAMEs - only if Route53 zone ID supplied
resource "aws_route53_record" "dkim" {
  count = var.route53_zone_id != "" ? 3 : 0

  zone_id = var.route53_zone_id
  name    = "${tolist(aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens)[count.index]}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = 600
  records = ["${tolist(aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens)[count.index]}.dkim.amazonses.com"]
}

# Custom MAIL FROM subdomain (improves deliverability + SPF alignment)
resource "aws_sesv2_email_identity_mail_from_attributes" "this" {
  count = var.mail_from_subdomain != "" ? 1 : 0

  email_identity         = aws_sesv2_email_identity.this.email_identity
  mail_from_domain       = "${var.mail_from_subdomain}.${var.domain}"
  behavior_on_mx_failure = "REJECT_MESSAGE"
}

resource "aws_route53_record" "mail_from_mx" {
  count = var.route53_zone_id != "" && var.mail_from_subdomain != "" ? 1 : 0

  zone_id = var.route53_zone_id
  name    = "${var.mail_from_subdomain}.${var.domain}"
  type    = "MX"
  ttl     = 600
  records = ["10 feedback-smtp.us-east-1.amazonses.com"]
}

resource "aws_route53_record" "mail_from_spf" {
  count = var.route53_zone_id != "" && var.mail_from_subdomain != "" ? 1 : 0

  zone_id = var.route53_zone_id
  name    = "${var.mail_from_subdomain}.${var.domain}"
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com -all"]
}

# DMARC record (always recommended)
resource "aws_route53_record" "dmarc" {
  count = var.route53_zone_id != "" ? 1 : 0

  zone_id = var.route53_zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = 600
  records = ["v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@${var.domain}; ruf=mailto:dmarc-reports@${var.domain}; fo=1; sp=quarantine"]
}

resource "aws_sesv2_configuration_set" "this" {
  configuration_set_name = var.configuration_set_name

  reputation_options {
    reputation_metrics_enabled = true
  }

  sending_options {
    sending_enabled = true
  }

  tracking_options {
    custom_redirect_domain = "click.${var.domain}"
  }

  tags = var.tags
}

resource "aws_sesv2_configuration_set_event_destination" "sns" {
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name
  event_destination_name = "bounces-and-complaints"

  event_destination {
    enabled = true
    matching_event_types = [
      "BOUNCE",
      "COMPLAINT",
      "DELIVERY",
      "REJECT",
      "RENDERING_FAILURE",
    ]

    sns_destination {
      topic_arn = var.bounce_complaint_topic_arn
    }
  }
}
