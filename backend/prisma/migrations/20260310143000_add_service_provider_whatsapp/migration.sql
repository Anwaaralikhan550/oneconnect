-- Add optional WhatsApp number for service providers
ALTER TABLE "service_providers"
ADD COLUMN "whatsapp" TEXT;
