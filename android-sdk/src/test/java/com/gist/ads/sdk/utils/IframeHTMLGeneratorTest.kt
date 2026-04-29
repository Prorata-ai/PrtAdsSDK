package com.gist.ads.sdk.utils

import org.junit.Assert.*
import org.junit.Test

class IframeHTMLGeneratorTest {
    
    @Test
    fun `generate appends theme with question mark when URL has no params`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "dark"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("https://example.com/ad?pr_theme=dark"))
    }
    
    @Test
    fun `generate appends theme with ampersand when URL has existing params`() {
        // Arrange
        val url = "https://example.com/ad?existing=param"
        val theme = "light"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("existing=param&pr_theme=light"))
    }
    
    @Test
    fun `generate escapes quotes in URL`() {
        // Arrange
        val url = "https://example.com/ad?param=\"value\""
        val theme = "system"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("&quot;"))
        assertFalse(result.contains("param=\"value\""))
    }
    
    @Test
    fun `generate includes allow-top-navigation-by-user-activation in sandbox`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "dark"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("allow-top-navigation-by-user-activation"))
    }
    
    @Test
    fun `generate includes all required sandbox permissions`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "light"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("allow-scripts"))
        assertTrue(result.contains("allow-same-origin"))
        assertTrue(result.contains("allow-forms"))
        assertTrue(result.contains("allow-popups"))
        assertTrue(result.contains("allow-popups-to-escape-sandbox"))
        assertTrue(result.contains("allow-top-navigation-by-user-activation"))
    }
    
    @Test
    fun `generate creates valid iframe structure`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "dark"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("<iframe"))
        assertTrue(result.contains("</iframe>"))
        assertTrue(result.contains("src="))
        assertTrue(result.contains("frameborder=\"0\""))
        assertTrue(result.contains("scrolling=\"no\""))
        assertTrue(result.contains("allowfullscreen"))
    }
    
    @Test
    fun `generate includes allow attribute for autoplay and payment`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "light"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("allow=\"autoplay; fullscreen; payment\""))
    }
    
    @Test
    fun `generate includes minimum height style`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "system"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("min-height:250px"))
    }
    
    @Test
    fun `generate handles complex URLs with multiple params`() {
        // Arrange
        val url = "https://example.com/ad?param1=value1&param2=value2&param3=value3"
        val theme = "dark"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("param1=value1&param2=value2&param3=value3&pr_theme=dark"))
    }
    
    @Test
    fun `generate handles URLs with fragment identifiers`() {
        // Arrange
        val url = "https://example.com/ad#section"
        val theme = "light"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("pr_theme=light"))
        assertTrue(result.contains("#section"))
    }
    
    @Test
    fun `generate with light theme creates correct URL`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "light"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("pr_theme=light"))
    }
    
    @Test
    fun `generate with dark theme creates correct URL`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "dark"
        
        // Act
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        assertTrue(result.contains("pr_theme=dark"))
    }
    
    @Test
    fun `generate with system theme creates correct URL`() {
        // Arrange
        val url = "https://example.com/ad"
        val theme = "system"
        
        // Act  
        val result = IframeHTMLGenerator.generate(url, theme)
        
        // Assert
        // Note: system should be resolved before calling generate, 
        // but if passed through it should still work
        assertTrue(result.contains("pr_theme=system"))
    }

    // --- normalizeTemplateId workaround tests ---

    @Test
    fun `normalizeTemplateId leaves URLs without pr_templateid unchanged`() {
        val url = "https://example.com/ad?foo=bar"
        assertEquals(url, IframeHTMLGenerator.normalizeTemplateId(url))
    }

    @Test
    fun `normalizeTemplateId leaves valid template aliases unchanged`() {
        val url = "https://example.com/ad?pr_templateid=text%2Fimage&pr_adimage=https%3A%2F%2Fexample.com%2Fimg.jpg"
        assertEquals(url, IframeHTMLGenerator.normalizeTemplateId(url))
    }

    @Test
    fun `normalizeTemplateId maps numeric 1 to text-image when image and text present`() {
        val url = "https://example.com/ad?pr_templateid=1&pr_adimage=https%3A%2F%2Fexample.com%2Fimg.jpg&pr_adtext=hello"
        val result = IframeHTMLGenerator.normalizeTemplateId(url)
        assertTrue(result.contains("pr_templateid=text%2Fimage"))
        assertFalse(result.contains("pr_templateid=1"))
        // Other params preserved
        assertTrue(result.contains("pr_adimage=https%3A%2F%2Fexample.com%2Fimg.jpg"))
        assertTrue(result.contains("pr_adtext=hello"))
    }

    @Test
    fun `normalizeTemplateId maps numeric 1 to image when only image present`() {
        val url = "https://example.com/ad?pr_templateid=1&pr_adimage=https%3A%2F%2Fexample.com%2Fimg.jpg"
        val result = IframeHTMLGenerator.normalizeTemplateId(url)
        assertTrue(result.contains("pr_templateid=image"))
    }

    @Test
    fun `normalizeTemplateId maps numeric 1 to text when only text present`() {
        val url = "https://example.com/ad?pr_templateid=1&pr_adtext=just+text"
        val result = IframeHTMLGenerator.normalizeTemplateId(url)
        assertTrue(result.contains("pr_templateid=text"))
    }

    @Test
    fun `normalizeTemplateId prefers explicit pr_adtype when present`() {
        val url = "https://example.com/ad?pr_templateid=1&pr_adtype=text%2Fanswer&pr_adtext=hi"
        val result = IframeHTMLGenerator.normalizeTemplateId(url)
        assertTrue(result.contains("pr_templateid=text%2Fanswer"))
    }

    @Test
    fun `normalizeTemplateId maps native id same as numeric 1`() {
        val url = "https://example.com/ad?pr_templateid=native&pr_adimage=https%3A%2F%2Fimg&pr_adtext=hi"
        val result = IframeHTMLGenerator.normalizeTemplateId(url)
        assertTrue(result.contains("pr_templateid=text%2Fimage"))
    }

    @Test
    fun `generate normalizes pr_templateid 1 in production-like URL`() {
        val url = "https://tp-at.prorata.ai/render_generic.html?pr_adimage=https%3A%2F%2Fimg&pr_adtext=hello&pr_templateid=1&pr_publisher=guest-api"
        val result = IframeHTMLGenerator.generate(url, "light")
        assertTrue(result.contains("pr_templateid=text%2Fimage"))
        assertFalse(result.contains("pr_templateid=1"))
        assertTrue(result.contains("pr_theme=light"))
    }
}
