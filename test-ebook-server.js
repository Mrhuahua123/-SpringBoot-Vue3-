const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const cors = require('cors');

const app = express();
const port = 8080;

// 创建上传目录
const uploadsDir = path.join(__dirname, 'campus-reading-backend', 'uploads');
const ebooksDir = path.join(uploadsDir, 'ebooks');

if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}
if (!fs.existsSync(ebooksDir)) {
    fs.mkdirSync(ebooksDir, { recursive: true });
}

// 配置multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, ebooksDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname);
        cb(null, uniqueSuffix + ext);
    }
});

const upload = multer({ 
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB
    }
});

// 中间件
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(uploadsDir));

// 模拟数据库
let books = [
    { id: 1, title: '活着', author: '余华', hasEbook: 1, ebookFile: null },
    { id: 2, title: '三体', author: '刘慈欣', hasEbook: 0, ebookFile: null },
    { id: 3, title: '百年孤独', author: '加西亚·马尔克斯', hasEbook: 0, ebookFile: null }
];

let chapters = [];

// 电子书上传接口
app.post('/api/ebook/upload/:bookId', upload.single('file'), (req, res) => {
    try {
        const bookId = parseInt(req.params.bookId);
        const book = books.find(b => b.id === bookId);
        
        if (!book) {
            return res.json({
                code: 404,
                message: '图书不存在'
            });
        }
        
        if (!req.file) {
            return res.json({
                code: 400,
                message: '请选择要上传的文件'
            });
        }
        
        // 检查文件类型
        const originalName = req.file.originalname.toLowerCase();
        if (!originalName.endsWith('.txt')) {
            return res.json({
                code: 400,
                message: '只支持TXT文件'
            });
        }
        
        const filePath = `/ebooks/${req.file.filename}`;
        
        // 更新图书信息
        book.ebookFile = filePath;
        book.hasEbook = 1;
        
        // 解析TXT文件内容
        const fullPath = path.join(ebooksDir, req.file.filename);
        const content = fs.readFileSync(fullPath, 'utf-8');
        
        // 简单解析章节（按行分割）
        const lines = content.split('\n').filter(line => line.trim());
        let chapterNum = 1;
        
        // 清除旧章节
        chapters = chapters.filter(c => c.bookId !== bookId);
        
        // 创建新章节
        for (let i = 0; i < lines.length; i += 10) {
            const chapterLines = lines.slice(i, i + 10);
            const chapterContent = chapterLines.join('\n');
            
            chapters.push({
                id: chapters.length + 1,
                bookId: bookId,
                chapterNum: chapterNum,
                title: `第${chapterNum}章`,
                content: chapterContent,
                wordCount: chapterContent.length,
                status: 1
            });
            
            chapterNum++;
        }
        
        res.json({
            code: 200,
            data: filePath,
            message: '电子书上传成功'
        });
        
    } catch (error) {
        console.error('上传错误:', error);
        res.json({
            code: 500,
            message: '上传失败: ' + error.message
        });
    }
});

// 获取章节目录
app.get('/api/reader/chapters/:bookId', (req, res) => {
    const bookId = parseInt(req.params.bookId);
    const bookChapters = chapters
        .filter(c => c.bookId === bookId && c.status === 1)
        .map(c => ({
            id: c.id,
            bookId: c.bookId,
            chapterNum: c.chapterNum,
            title: c.title,
            wordCount: c.wordCount,
            status: c.status
            // 不返回content
        }))
        .sort((a, b) => a.chapterNum - b.chapterNum);
    
    res.json({
        code: 200,
        data: bookChapters
    });
});

// 获取章节内容
app.get('/api/reader/chapter/:id', (req, res) => {
    const chapterId = parseInt(req.params.id);
    const chapter = chapters.find(c => c.id === chapterId);
    
    if (!chapter) {
        return res.json({
            code: 404,
            message: '章节不存在'
        });
    }
    
    res.json({
        code: 200,
        data: chapter
    });
});

// 获取章节导航
app.get('/api/reader/chapter/:id/nav', (req, res) => {
    const chapterId = parseInt(req.params.id);
    const chapter = chapters.find(c => c.id === chapterId);
    
    if (!chapter) {
        return res.json({
            code: 404,
            message: '章节不存在'
        });
    }
    
    const bookChapters = chapters
        .filter(c => c.bookId === chapter.bookId && c.status === 1)
        .sort((a, b) => a.chapterNum - b.chapterNum);
    
    const currentIndex = bookChapters.findIndex(c => c.id === chapterId);
    
    const nav = {
        current: {
            id: chapter.id,
            title: chapter.title,
            chapterNum: chapter.chapterNum
        },
        prev: currentIndex > 0 ? {
            id: bookChapters[currentIndex - 1].id,
            title: bookChapters[currentIndex - 1].title
        } : null,
        next: currentIndex < bookChapters.length - 1 ? {
            id: bookChapters[currentIndex + 1].id,
            title: bookChapters[currentIndex + 1].title
        } : null
    };
    
    res.json({
        code: 200,
        data: nav
    });
});

// 获取图书列表
app.get('/api/books', (req, res) => {
    res.json({
        code: 200,
        data: books
    });
});

// 启动服务器
app.listen(port, () => {
    console.log(`电子书测试服务器运行在 http://localhost:${port}`);
    console.log(`上传目录: ${ebooksDir}`);
    console.log(`测试电子书文件: ${path.join(__dirname, 'test-ebook.txt')}`);
    console.log('\n可用接口:');
    console.log('1. GET  /api/books - 获取图书列表');
    console.log('2. POST /api/ebook/upload/:bookId - 上传电子书');
    console.log('3. GET  /api/reader/chapters/:bookId - 获取章节目录');
    console.log('4. GET  /api/reader/chapter/:id - 获取章节内容');
    console.log('5. GET  /api/reader/chapter/:id/nav - 获取章节导航');
});