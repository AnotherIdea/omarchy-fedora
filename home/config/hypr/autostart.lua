-- GTK 4.20+ on Wayland drops Compose unless an input module is set.
-- environment.d already exports this for systemd-activated apps.
hl.env("GTK_IM_MODULE", "simple")
hl.env("OMARCHY_OCR_LANGS", "fra+eng")
