# 鐢靛瓙涔﹀姛鑳芥祴璇曡剼鏈?Write-Host "=== 鐢靛瓙涔﹀姛鑳芥祴璇?===" -ForegroundColor Green

# 1. 妫€鏌ユ暟鎹簱杩炴帴
Write-Host "1. 妫€鏌ユ暟鎹簱杩炴帴..." -ForegroundColor Yellow
try {
    $result = mysql -u root -p123456 -e "USE campus_reading; SELECT COUNT(*) as book_count FROM t_book;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "鏁版嵁搴撹繛鎺ユ垚鍔? -ForegroundColor Green
        Write-Host "褰撳墠鍥句功鏁伴噺: $result" -ForegroundColor Cyan
    } else {
        Write-Host "鏁版嵁搴撹繛鎺ュけ璐? $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "鏁版嵁搴撹繛鎺ュ紓甯? $_" -ForegroundColor Red
    exit 1
}

# 2. 妫€鏌ヨ〃缁撴瀯
Write-Host "`n2. 妫€鏌ョ數瀛愪功鐩稿叧琛ㄧ粨鏋?.." -ForegroundColor Yellow
$tables = @("t_book", "t_chapter")
foreach ($table in $tables) {
    $result = mysql -u root -p123456 -e "USE campus_reading; DESCRIBE $table;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$table 琛ㄧ粨鏋勬甯? -ForegroundColor Green
    } else {
        Write-Host "$table 琛ㄦ鏌ュけ璐? $result" -ForegroundColor Red
    }
}

# 3. 鍒涘缓娴嬭瘯鍥句功
Write-Host "`n3. 鍒涘缓娴嬭瘯鍥句功..." -ForegroundColor Yellow
$testBookSql = @"
INSERT INTO t_book (title, author, publisher, description, status) 
VALUES ('娴嬭瘯鐢靛瓙涔?, '娴嬭瘯浣滆€?, '娴嬭瘯鍑虹増绀?, '杩欐槸涓€涓敤浜庢祴璇曠數瀛愪功鍔熻兘鐨勫浘涔?, 1);
SELECT LAST_INSERT_ID() as new_book_id;
"@

$bookResult = mysql -u root -p123456 -e "USE campus_reading; $testBookSql" 2>&1
if ($LASTEXITCODE -eq 0) {
    $bookId = ($bookResult -split "`n")[1]
    Write-Host "娴嬭瘯鍥句功鍒涘缓鎴愬姛锛孖D: $bookId" -ForegroundColor Green
} else {
    Write-Host "娴嬭瘯鍥句功鍒涘缓澶辫触: $bookResult" -ForegroundColor Red
    $bookId = 1  # 浣跨敤榛樿ID
}

# 4. 妫€鏌ava鏂囦欢缂栫爜
Write-Host "`n4. 妫€鏌ava鏂囦欢缂栫爜..." -ForegroundColor Yellow
$javaFiles = @(
    "campus-reading-backend\src\main\java\com\example\campusreading\controller\EbookController.java",
    "campus-reading-backend\src\main\java\com\example\campusreading\service\EbookService.java",
    "campus-reading-backend\src\main\java\com\example\campusreading\utils\EbookParser.java",
    "campus-reading-backend\src\main\java\com\example\campusreading\controller\ReaderController.java"
)

foreach ($file in $javaFiles) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($content -match "[^\x00-\x7F]") {
            Write-Host "$file 鍖呭惈闈濧SCII瀛楃锛屽彲鑳芥槸UTF-8缂栫爜" -ForegroundColor Cyan
        } else {
            Write-Host "$file 缂栫爜姝ｅ父" -ForegroundColor Green
        }
    } else {
        Write-Host "$file 涓嶅瓨鍦? -ForegroundColor Red
    }
}

# 5. 妫€鏌ploads鐩綍
Write-Host "`n5. 妫€鏌ヤ笂浼犵洰褰?.." -ForegroundColor Yellow
$uploadDirs = @("campus-reading-backend\uploads", "campus-reading-backend\uploads\ebooks", "campus-reading-backend\uploads\avatars")
foreach ($dir in $uploadDirs) {
    $fullPath = Join-Path $PSScriptRoot $dir
    if (Test-Path $fullPath) {
        Write-Host "$dir 鐩綍宸插瓨鍦? -ForegroundColor Green
    } else {
        Write-Host "鍒涘缓鐩綍: $dir" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}

# 6. 妫€鏌ユ祴璇曠數瀛愪功鏂囦欢
Write-Host "`n6. 妫€鏌ユ祴璇曠數瀛愪功鏂囦欢..." -ForegroundColor Yellow
$testEbookPath = Join-Path $PSScriptRoot "test-ebook.txt"
if (Test-Path $testEbookPath) {
    $fileSize = (Get-Item $testEbookPath).Length
    $lineCount = (Get-Content $testEbookPath).Count
    Write-Host "娴嬭瘯鐢靛瓙涔︽枃浠跺瓨鍦? -ForegroundColor Green
    Write-Host "鏂囦欢澶у皬: $fileSize 瀛楄妭" -ForegroundColor Cyan
    Write-Host "琛屾暟: $lineCount" -ForegroundColor Cyan
    
    # 鏄剧ず鍓?琛屽唴瀹?    Write-Host "`n鏂囦欢鍐呭棰勮:" -ForegroundColor Yellow
    Get-Content $testEbookPath -TotalCount 3 | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "娴嬭瘯鐢靛瓙涔︽枃浠朵笉瀛樺湪" -ForegroundColor Red
}

# 7. 妫€鏌ュ墠绔疉PI鏂囦欢
Write-Host "`n7. 妫€鏌ュ墠绔疉PI鏂囦欢..." -ForegroundColor Yellow
$apiFiles = @(
    "campus-reading-frontend\src\api\ebook.js",
    "campus-reading-frontend\src\api\reader.js"
)

foreach ($file in $apiFiles) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        Write-Host "$file 瀛樺湪" -ForegroundColor Green
    } else {
        Write-Host "$file 涓嶅瓨鍦? -ForegroundColor Red
        if ($file -like "*reader.js") {
            Write-Host "鍒涘缓reader.js API鏂囦欢..." -ForegroundColor Yellow
            $readerApi = @"
import http from './http'

// 鑾峰彇绔犺妭鐩綍
export const getChapterList = (bookId) => {
  return http.get(`/reader/chapters/${bookId}`)
}

// 鑾峰彇绔犺妭鍐呭
export const getChapterContent = (chapterId) => {
  return http.get(`/reader/chapter/${chapterId}`)
}

// 鑾峰彇绔犺妭瀵艰埅
export const getChapterNav = (chapterId) => {
  return http.get(`/reader/chapter/${chapterId}/nav`)
}
"@
            Set-Content -Path $fullPath -Value $readerApi -Encoding UTF8
            Write-Host "宸插垱寤?$file" -ForegroundColor Green
        }
    }
}

Write-Host "`n=== 娴嬭瘯瀹屾垚 ===" -ForegroundColor Green
Write-Host "涓嬩竴姝ユ搷浣?" -ForegroundColor Yellow
Write-Host "1. 鍚姩鍚庣鏈嶅姟: cd campus-reading-backend && mvn spring-boot:run" -ForegroundColor Cyan
Write-Host "2. 鍚姩鍓嶇鏈嶅姟: cd campus-reading-frontend && npm run dev" -ForegroundColor Cyan
Write-Host "3. 娴嬭瘯鐢靛瓙涔︿笂浼犲姛鑳? -ForegroundColor Cyan
Write-Host "4. 娴嬭瘯鐢靛瓙涔﹂槄璇诲姛鑳? -ForegroundColor Cyan