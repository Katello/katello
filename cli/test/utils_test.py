import unittest
import os

from katello.client.core.utils import convert_to_mime_type

class ConvertToMimeTest(unittest.TestCase):
    
    def test_text_conversion(self):
        self.assertEqual('text/plain', convert_to_mime_type('text'))
        
    def test_html_conversion(self):
        self.assertEqual('text/html', convert_to_mime_type('html'))
        
    def test_csv_conversion(self):
        self.assertEqual('text/csv', convert_to_mime_type('csv'))
        
    def test_pdf_conversion(self):
        self.assertEqual('application/pdf', convert_to_mime_type('pdf'))
        
    def test_default_type(self):
        self.assertEqual('text/plain', convert_to_mime_type('blah', 'text'))
