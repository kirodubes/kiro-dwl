/* Kiro dwlb config — Tokyo Night, baked into the dwlb bar binary by the
 * kiro-dwl recipe. ipc=true uses dwl's dwl-ipc-unstable-v2 (needs the ipc
 * patch on dwl) for live, clickable tags. Suckless: edit + kiro-dwl-rebuild. */
#define HEX_COLOR(hex)				\
	{ .red   = ((hex >> 24) & 0xff) * 257,	\
	  .green = ((hex >> 16) & 0xff) * 257,	\
	  .blue  = ((hex >> 8) & 0xff) * 257,	\
	  .alpha = (hex & 0xff) * 257 }

static bool ipc = true;           /* talk to dwl over dwl-ipc-unstable-v2 (clickable tags) */
static bool hidden = false;
static bool bottom = false;
static bool hide_vacant = false;
static uint32_t vertical_padding = 2;
static bool status_commands = true;
static bool center_title = false;
static bool custom_title = false;
static bool active_color_title = true;
static uint32_t buffer_scale = 1;
static char *fontstr = "JetBrainsMono Nerd Font:size=12";
static char *tags_names[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* Tokyo Night */
static pixman_color_t active_fg_color   = HEX_COLOR(0x1a1b26ff);
static pixman_color_t active_bg_color   = HEX_COLOR(0x7aa2f7ff);
static pixman_color_t occupied_fg_color = HEX_COLOR(0x7aa2f7ff);
static pixman_color_t occupied_bg_color = HEX_COLOR(0x1a1b26ff);
static pixman_color_t inactive_fg_color = HEX_COLOR(0x565f89ff);
static pixman_color_t inactive_bg_color = HEX_COLOR(0x1a1b26ff);
static pixman_color_t urgent_fg_color   = HEX_COLOR(0x1a1b26ff);
static pixman_color_t urgent_bg_color   = HEX_COLOR(0xf7768eff);
static pixman_color_t middle_bg_color   = HEX_COLOR(0x1a1b26ff);
static pixman_color_t middle_bg_color_selected = HEX_COLOR(0x7aa2f7ff);
