resource "aws_route53_record" "mx" {
    zone_id = local.hosted_zone
    name    = local.apex_domain
    type    = "MX"
    ttl     = 300
    records = [
        "10 mail.protonmail.ch",
        "20 mailsec.protonmail.ch"
    ]
}
resource "aws_route53_record" "ns" {
    zone_id = local.hosted_zone
    name    = local.apex_domain
    type    = "NS"
    ttl     = 300
    records = [
        "ns-1969.awsdns-54.co.uk.",
        "ns-831.awsdns-39.net.",
        "ns-300.awsdns-37.com.",
        "ns-1391.awsdns-45.org."
    ]
}
resource "aws_route53_record" "soa" {
    zone_id = local.hosted_zone
    name    = local.apex_domain
    type    = "SOA"
    ttl     = 300
    records = ["ns-1969.awsdns-54.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
}
resource "aws_route53_record" "txt" {
    zone_id = local.hosted_zone
    name    = local.apex_domain
    type    = "TXT"
    ttl     = 300
    records = [
        "protonmail-verification=78c74c851e6fd181f96fe6994e6e325672365710",
        "trivialsec=afcd1bcf5069abe16ebb389e4541a6258c3747937e51e4bcbb6d77e9",
        "v=spf1 include:_spf.protonmail.ch mx ~all",
        "stripe-verification=4935d976effc22438dcf972d5f414dec1436b7d950d5239348e8330334749d90",
    ]
}
resource "aws_route53_record" "sendgrid_cname" {
    zone_id = local.hosted_zone
    name    = "18209934.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["sendgrid.net"]
}
resource "aws_route53_record" "acm_cname" {
    zone_id = local.hosted_zone
    name    = "_05f1a0310986daa4456de17adf6c577c.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["_6248be44780169afe8ba8350aaba228d.zdxcnfdgtt.acm-validations.aws."]
}
resource "aws_route53_record" "dmarc" {
    zone_id = local.hosted_zone
    name    = "_dmarc.${local.apex_domain}"
    type    = "TXT"
    ttl     = 300
    records = ["v=DMARC1; p=none; rua=mailto:support@langton.cloud"]
}
resource "aws_route53_record" "stripe_dkim_0" {
    zone_id = local.hosted_zone
    name    = "7f4vmiydjh6r6mb7fvhofbzigwnbfdoc._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["7f4vmiydjh6r6mb7fvhofbzigwnbfdoc.dkim.custom-email-domain.stripe.com."]
}
resource "aws_route53_record" "stripe_dkim_1" {
    zone_id = local.hosted_zone
    name    = "gwvhtyoajckywot722als6g3dr7nocdr._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["gwvhtyoajckywot722als6g3dr7nocdr.dkim.custom-email-domain.stripe.com."]
}
resource "aws_route53_record" "stripe_dkim_2" {
    zone_id = local.hosted_zone
    name    = "h3kmfl53gppj2sj6sc5uzhbhpywo7ocs._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["h3kmfl53gppj2sj6sc5uzhbhpywo7ocs.dkim.custom-email-domain.stripe.com."]
}
resource "aws_route53_record" "stripe_dkim_3" {
    zone_id = local.hosted_zone
    name    = "k7a47un3ogrg2fxnxiifqlw5rfc7jwyy._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["k7a47un3ogrg2fxnxiifqlw5rfc7jwyy.dkim.custom-email-domain.stripe.com."]
}
resource "aws_route53_record" "stripe_dkim_4" {
    zone_id = local.hosted_zone
    name    = "psnhclq5unzzerruurb47v32zf42ljyn._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["psnhclq5unzzerruurb47v32zf42ljyn.dkim.custom-email-domain.stripe.com."]
}
resource "aws_route53_record" "stripe_dkim_5" {
    zone_id = local.hosted_zone
    name    = "x7rurwqmif4k43x7a5wkltshswar6vm3._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["x7rurwqmif4k43x7a5wkltshswar6vm3.dkim.custom-email-domain.stripe.com."]
}
resource "aws_route53_record" "protonmail_dkim_0" {
    zone_id = local.hosted_zone
    name    = "protonmail._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["protonmail.domainkey.dwpdkrbnojqkv3vv5ugaybesokkv6qo25yswqpd3sphzabe3i5yza.domains.proton.ch."]
}
resource "aws_route53_record" "protonmail_dkim_1" {
    zone_id = local.hosted_zone
    name    = "protonmail2._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["protonmail2.domainkey.dwpdkrbnojqkv3vv5ugaybesokkv6qo25yswqpd3sphzabe3i5yza.domains.proton.ch."]
}
resource "aws_route53_record" "protonmail_dkim_2" {
    zone_id = local.hosted_zone
    name    = "protonmail3._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["protonmail3.domainkey.dwpdkrbnojqkv3vv5ugaybesokkv6qo25yswqpd3sphzabe3i5yza.domains.proton.ch."]
}
resource "aws_route53_record" "sendgrid_dkim_0" {
    zone_id = local.hosted_zone
    name    = "s1._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["s1.domainkey.u18209934.wl185.sendgrid.net"]
}
resource "aws_route53_record" "sendgrid_dkim_1" {
    zone_id = local.hosted_zone
    name    = "s2._domainkey.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["s2.domainkey.u18209934.wl185.sendgrid.net"]
}
resource "aws_route53_record" "stripe_bounce" {
    zone_id = local.hosted_zone
    name    = "bounce.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["custom-email-domain.stripe.com."]
}
resource "aws_route53_record" "sendgrid_tracker_0" {
    zone_id = local.hosted_zone
    name    = "em8876.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["u18209934.wl185.sendgrid.net"]
}
resource "aws_route53_record" "sendgrid_tracker_1" {
    zone_id = local.hosted_zone
    name    = "url2567.${local.apex_domain}"
    type    = "CNAME"
    ttl     = 300
    records = ["sendgrid.net"]
}
resource "aws_route53_record" "mail" {
    zone_id = local.hosted_zone
    name    = "mail.${local.apex_domain}"
    type    = "A"
    ttl     = 300
    records = ["13.238.101.94"]
}
resource "aws_route53_record" "mail_mx" {
    zone_id = local.hosted_zone
    name    = "mail.${local.apex_domain}"
    type    = "MX"
    ttl     = 300
    records = ["10 smtp5.mxmailer.org."]
}
resource "aws_route53_record" "proxy" {
    zone_id = local.hosted_zone
    name    = "proxy.${local.apex_domain}"
    type    = "A"
    ttl     = 300
    records = ["54.79.237.235"]
}
resource "aws_route53_record" "status_ns" {
    zone_id = local.hosted_zone
    name    = "status.${local.apex_domain}"
    type    = "NS"
    ttl     = 300
    records = [
        "ns1.digitalocean.com",
        "ns2.digitalocean.com",
        "ns3.digitalocean.com"
    ]
}
