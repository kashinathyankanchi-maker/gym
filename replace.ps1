$dir = "C:\Users\Asus1\.gemini\antigravity\scratch\hemant_gym\lib"
$files = Get-ChildItem -Path $dir -Recurse -Filter "*.dart"

$replacements = @{
    "import 'package:lucide_icons/lucide_icons.dart';" = ""
    "LucideIcons.home" = "Icons.home"
    "LucideIcons.users" = "Icons.people"
    "LucideIcons.clock" = "Icons.access_time"
    "LucideIcons.dollarSign" = "Icons.attach_money"
    "LucideIcons.menu" = "Icons.menu"
    "LucideIcons.bell" = "Icons.notifications"
    "LucideIcons.userCheck" = "Icons.how_to_reg"
    "LucideIcons.wallet" = "Icons.account_balance_wallet"
    "LucideIcons.fileText" = "Icons.receipt"
    "LucideIcons.calendar" = "Icons.calendar_today"
    "LucideIcons.plus" = "Icons.add"
    "LucideIcons.search" = "Icons.search"
    "LucideIcons.chevronRight" = "Icons.chevron_right"
    "LucideIcons.chevronLeft" = "Icons.chevron_left"
    "LucideIcons.phone" = "Icons.phone"
    "LucideIcons.messageCircle" = "Icons.message"
    "LucideIcons.qrCode" = "Icons.qr_code"
    "LucideIcons.arrowLeft" = "Icons.arrow_back"
    "LucideIcons.banknote" = "Icons.money"
    "LucideIcons.creditCard" = "Icons.credit_card"
    "LucideIcons.moreHorizontal" = "Icons.more_horiz"
    "LucideIcons.clipboardList" = "Icons.list_alt"
    "LucideIcons.dumbbell" = "Icons.fitness_center"
    "LucideIcons.messageSquare" = "Icons.chat"
    "LucideIcons.cloud" = "Icons.cloud"
    "LucideIcons.settings" = "Icons.settings"
    "LucideIcons.helpCircle" = "Icons.help_outline"
    "LucideIcons.info" = "Icons.info_outline"
    "LucideIcons.activity" = "Icons.local_activity"
}

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    $original = $content
    foreach ($key in $replacements.Keys) {
        $content = $content.Replace($key, $replacements[$key])
    }
    if ($content -cne $original) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated $($file.FullName)"
    }
}
