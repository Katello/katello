import unittest

from katello.client.lib.utils.io import convert_to_mime_type, attachment_file_name
from katello.client.lib.utils.data import slice_dict

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


class AttachmentFilenameTest(unittest.TestCase):

    FILENAME = 'test_file.txt'
    DEFAULT_FILENAME = 'default.txt'

    def test_uses_filename_in_content_disposition_header(self):
        self.assertEqual(self.FILENAME, attachment_file_name([
            ('content-type', 'application/pdf'),
            ('cache-control', 'private'),
            ('content-disposition', 'attachment; filename="' + self.FILENAME + '"')], self.DEFAULT_FILENAME))

    def test_handles_capitalized_header_name(self):
        self.assertEqual(self.FILENAME, attachment_file_name([
            ('content-type', 'application/pdf'),
            ('cache-control', 'private'),
            ('Content-Disposition', 'attachment; filename="' + self.FILENAME + '"')], self.DEFAULT_FILENAME))

    def test_uses_default_filename_without_content_disposition_header(self):
        self.assertEqual(self.DEFAULT_FILENAME, attachment_file_name([
            ('content-type', 'application/pdf'),
            ('cache-control', 'private')], self.DEFAULT_FILENAME))

    def test_uses_default_filename_with_incomplete_content_disposition_header(self):
        self.assertEqual(self.DEFAULT_FILENAME, attachment_file_name([
            ('content-type', 'application/pdf'),
            ('cache-control', 'private'),
            ('content-disposition')], self.DEFAULT_FILENAME))


class SliceDictTest(unittest.TestCase):

    test_dict = {
        "A": "a",
        "B": "b",
        "C": "c",
        "D": None
    }

    def test_returns_empty_dict_if_no_keys_specified(self):
        self.assertEqual(
            slice_dict(self.test_dict),
            {}
        )

    def test_slices_dict(self):
        self.assertEqual(
            slice_dict(self.test_dict, "A"),
            {"A": "a"}
        )

    def test_slices_dict_with_all_its_original_keys(self):
        self.assertEqual(
            slice_dict(self.test_dict, "A", "B", "C", "D"),
            self.test_dict
        )

    def test_slices_dict_with_all_its_original_keys_and_filtered_nones(self):
        self.assertEqual(
            slice_dict(self.test_dict, "A", "B", "C", "D", allow_none=False),
            {"A": "a", "B": "b", "C": "c"}
        )

    def test_slices_dict_with_none_of_its_original_keys(self):
        self.assertEqual(
            slice_dict(self.test_dict, "Y", "Z"),
            {}
        )

    def test_slices_dict_with_one_of_its_original_keys(self):
        self.assertEqual(
            slice_dict(self.test_dict, "A", "Z"),
            {"A": "a"}
        )

