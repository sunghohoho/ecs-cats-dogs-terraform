# resource "aws_acm_certificate" "cert" {
#   domain_name       = "unknown"
#   validation_method = "DNS"

#   validation_option {
#     domain_name       = "unknown"
#     validation_domain = "unknown"
#   }
# }

resource "aws_acm_certificate" "cert" {
    #arn                       = "arn:aws:acm:us-east-1:866477832211:certificate/f651979e-5410-4021-85ce-44ccebb0685a"
    domain_name               = "*.gguduck.com"
    # domain_validation_options = [
    #     {
    #         domain_name           = "*.gguduck.com"
    #         resource_record_name  = "_f50d678e59720305cec9f636afd924b7.gguduck.com."
    #         resource_record_type  = "CNAME"
    #         resource_record_value = "_a699e93cd97b2da8447b2f7187b92d2b.lkwmzfhcjn.acm-validations.aws."
    #     },
    #     {
    #         domain_name           = "gguduck.com"
    #         resource_record_name  = "_f50d678e59720305cec9f636afd924b7.gguduck.com."
    #         resource_record_type  = "CNAME"
    #         resource_record_value = "_a699e93cd97b2da8447b2f7187b92d2b.lkwmzfhcjn.acm-validations.aws."
    #     },
    # ]
    #id                        = "arn:aws:acm:us-east-1:866477832211:certificate/f651979e-5410-4021-85ce-44ccebb0685a"
    key_algorithm             = "RSA_2048"
    #not_after                 = "2024-10-17T23:59:59Z"
    #not_before                = "2023-09-19T00:00:00Z"
    #pending_renewal           = false
    #renewal_eligibility       = "ELIGIBLE"
    # renewal_summary           = [
    #     {
    #         renewal_status        = "SUCCESS"
    #         renewal_status_reason = ""
    #         updated_at            = "2023-09-19T10:54:32Z"
    #     },
    # ]
    #status                    = "ISSUED"
    subject_alternative_names = [
        "*.gguduck.com",
        "gguduck.com",
    ]
    tags                      = {}
    tags_all                  = {}
    #type                      = "AMAZON_ISSUED"
    #validation_emails         = []
    validation_method         = "DNS"

    options {
        certificate_transparency_logging_preference = "ENABLED"
    }
}